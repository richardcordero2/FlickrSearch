//
//  FlickrDownloadManager.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FlickrPhotosCompletionBlock)(NSArray * __nullable flickrPhotoObjects, NSError * __nullable error);
typedef void(^FlickrImageCompletionBlock)(UIImage * __nullable image, NSError * __nullable error);

@interface FlickrDownloadManager : NSObject

#pragma mark - Methods
- (void)downloadFlickrPhotoObjectsWithKeyword:(NSString *)keyword  pageNumber:(NSNumber *)pageNumber completionBlock:(FlickrPhotosCompletionBlock)completionBlock;
- (void)downloadFlickrPhotoWithFarm:(NSString *)farm
                             server:(NSString *)server
                            photoId:(NSString *)photoId
                             secret:(NSString *)secret
                    completionBlock:(FlickrImageCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
