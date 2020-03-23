//
//  FlickrDownloadManager.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrDownloadManager.h"
#import "FSHTTPSessionManager.h"
#import "AFImageDownloader.h"

@interface FlickrDownloadManager ()

// Store all image download receipts for the option to cancel them.
@property NSMutableArray *imageDownloadReceipts;

@end

@implementation FlickrDownloadManager

static NSString * const FlickrAPPIKey = @"96358825614a5d3b1a1c3fd87fca2b47";
static NSString * const FlickrAPIMethod = @"flickr.photos.search";
static NSString * const FlickrAPIFormat = @"json";
static NSString * const FlickrAPINoJSONCallback = @"1";

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageDownloadReceipts = [NSMutableArray new];
    }
    return self;
}

/* Call the Flickr Search public API with a keyword.
   Return: An array of dictionaries returned by the API through a completion block. */
- (void)downloadFlickrPhotoObjectsWithKeyword:(NSString *)keyword pageNumber:(NSNumber *)pageNumber completionBlock:(FlickrPhotosCompletionBlock)completionBlock {
    
    // Before executing a new search, cancel all existing image download requests.
    [self cancelPendingImageDownloads];
    
    // Build the URL and Parameters
    NSString *url = @"/services/rest/";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:FlickrAPIMethod forKey:@"method"];
    [parameters setObject:FlickrAPPIKey forKey:@"api_key"];
    [parameters setObject:FlickrAPIFormat forKey:@"format"];
    [parameters setObject:FlickrAPINoJSONCallback forKey:@"nojsoncallback"];
    
    if (keyword) {
        [parameters setObject:keyword forKey:@"text"];
    }
    if (pageNumber) {
        [parameters setObject:pageNumber forKey:@"page"];
    }
    
    [[FSHTTPSessionManager sharedFlickrJSONAPIClient] GET:url
                                               parameters:parameters
                                                 progress:nil
                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // Flickr Search Succeeded
        NSLog(@"Flickr Search Succeeded: %@", [[[task currentRequest] URL] absoluteURL]);
        
        NSArray *flickPhotoObjectsArray;
        // If stat is ok, assume photos and photo array exist within the responseObject and collect it.
        if ([[responseObject valueForKey:@"stat"] isEqualToString:@"ok"]) {
            flickPhotoObjectsArray = [[responseObject valueForKey:@"photos"] valueForKey:@"photo"];
        }
        
        // Return the array of Flickr objects
        if (completionBlock) {
            completionBlock(flickPhotoObjectsArray, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // Flickr Search Succeeded
        NSLog(@"Flickr Search Failed: %@", [error localizedDescription]);
        
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

/* Downloads a specific Flickr image.
   Return: The UIImage data through a completion block. */
- (void)downloadFlickrPhotoWithFarm:(NSString *)farm
                             server:(NSString *)server
                            photoId:(NSString *)photoId
                             secret:(NSString *)secret
                    completionBlock:(FlickrImageCompletionBlock)completionBlock {
    
    // Build the URL with the provided parameters
    NSString *url = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@.jpg", farm, server, photoId, secret];
    AFImageDownloader *afImageDownloader = [AFImageDownloader defaultInstance];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
    
    // Execute image download. Store the receipt for future use.
    __block AFImageDownloadReceipt *imageDownloadReceipt = [afImageDownloader downloadImageForURLRequest:request success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
        // Flickr Static Download Succeeded
        UIImage *imageData = (UIImage *)responseObject;
        
        // Return the array of Flickr objects
        if (completionBlock) {
            completionBlock(imageData, nil);
        }
        
        // Image download finished. Remove the receipt from the collection.
        [self.imageDownloadReceipts removeObject:imageDownloadReceipt];
    }failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        // Flickr Search Succeeded
        NSLog(@"Flickr Search Failed: %@", [error localizedDescription]);
        
        if (completionBlock) {
            completionBlock(nil, error);
        }
        
        // Image download finished. Remove the receipt from the collection.
        [self.imageDownloadReceipts removeObject:imageDownloadReceipt];
    }];
    
    // Store receipt
    if (imageDownloadReceipt) {
        [self.imageDownloadReceipts addObject:imageDownloadReceipt];
    }
}

// Cancel all pending image downloads.
- (void)cancelPendingImageDownloads {
    for (AFImageDownloadReceipt *receipt in self.imageDownloadReceipts) {
        NSLog(@"Cancelling Image Download Request ID: %@", [receipt.receiptID UUIDString]);
        [[AFImageDownloader defaultInstance] cancelTaskForImageDownloadReceipt:receipt];
    }
    self.imageDownloadReceipts = [NSMutableArray new];
}

@end
