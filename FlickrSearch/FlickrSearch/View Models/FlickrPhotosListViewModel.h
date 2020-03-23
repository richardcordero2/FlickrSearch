//
//  FlickrPhotosListViewModel.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/23/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FlickrPhotoViewModel;
@class FlickrDownloadManager;

typedef void(^CompletionBlock)(NSError * __nullable error);

@interface FlickrPhotosListViewModel : NSObject

#pragma mark - Methods
- (instancetype)initWithDownloadManager:(FlickrDownloadManager *)downloadManager;
- (void)downloadFlickrPhotosWithKeyword:(NSString *)keyword completionBlock:(CompletionBlock)completionBlock;
- (void)downloadNextPage:(CompletionBlock)completionBlock;
- (NSArray *)getFlickrPhotosList;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
