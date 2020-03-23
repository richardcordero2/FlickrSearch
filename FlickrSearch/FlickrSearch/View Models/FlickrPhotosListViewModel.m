//
//  FlickrPhotosListViewModel.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrPhotosListViewModel.h"
#import "FlickrPhotoViewModel.h"
#import "FlickrDownloadManager.h"
#import "FlickrPhotoObject.h"

@interface FlickrPhotosListViewModel ()

@property FlickrDownloadManager *downloadManager;

@property NSMutableArray *flickrPhotosArray;
@property NSString *keyword;
@property NSInteger topPageNumber;

@end

@implementation FlickrPhotosListViewModel

- (instancetype)initWithDownloadManager:(FlickrDownloadManager *)downloadManager {
    self = [super init];
    if (self) {
        self.downloadManager = downloadManager;
        self.flickrPhotosArray = [NSMutableArray new];
    }
    return self;
}

- (void)downloadFlickrPhotosWithKeyword:(NSString *)keyword completionBlock:(CompletionBlock)completionBlock {
    // Call the Flickr Search API with the given keyword.
    self.topPageNumber = 1;
    self.keyword = keyword;
    [self downloadFlickrPhotosWithKeyword:keyword pageNumber:@(self.topPageNumber) completionBlock:completionBlock];
}

- (void)downloadNextPage:(CompletionBlock)completionBlock {
    self.topPageNumber++;
    [self downloadFlickrPhotosWithKeyword:self.keyword pageNumber:@(self.topPageNumber) completionBlock:completionBlock];
}

- (void)downloadFlickrPhotosWithKeyword:(NSString *)keyword pageNumber:(NSNumber *)pageNumber completionBlock:(CompletionBlock)completionBlock {
    [self.downloadManager downloadFlickrPhotoObjectsWithKeyword:keyword pageNumber:pageNumber completionBlock:^(NSArray * _Nullable flickrPhotoObjects, NSError * _Nullable error) {
        if (error == nil) {
            // Convert the reponse NSDictionary to FlickrPhotoViewModel instances and store in the list property as the main data source.
            for (NSDictionary *flickrPhotoDict in flickrPhotoObjects) {
                FlickrPhotoObject *flickrPhotoObject = [[FlickrPhotoObject alloc] initWithDictionary:flickrPhotoDict];
                FlickrPhotoViewModel *flickrPhotoVM = [[FlickrPhotoViewModel alloc] initWithFlickrPhotoObject:flickrPhotoObject];
                [self.flickrPhotosArray addObject:flickrPhotoVM];
            }
            
            // Notify the caller.
            if (completionBlock) {
                completionBlock(nil);
            }
        } else {
            // Notify the caller.
            if (completionBlock) {
                completionBlock(error);
            }
        }
    }];
}

- (NSArray *)getFlickrPhotosList {
    return [self.flickrPhotosArray copy];
}

- (void)clear {
    _topPageNumber = 0;
    self.flickrPhotosArray = [NSMutableArray new];
}

@end
