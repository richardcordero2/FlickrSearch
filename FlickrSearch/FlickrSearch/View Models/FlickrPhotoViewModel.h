//
//  FlickrPhoto.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FlickrPhotoObject;
@class FlickrDownloadManager;

typedef void(^CompletionBlock)(NSError * __nullable error);

@interface FlickrPhotoViewModel : NSObject

@property FlickrPhotoObject *flickrPhotoObject;

#pragma mark - Properties

#pragma mark - Methods
// Custom constructor.
- (instancetype)initWithFlickrPhotoObject:(FlickrPhotoObject *)flickrPhotoObject;

// Asynchronously request the Flickr static image.
- (void)requestFlickrImageWithDownloadManager:(FlickrDownloadManager *)downloadManager completionBlock:(CompletionBlock)completionBlock;

// Return the image title.
- (UIImage *)getImageData;

// Return the image title.
- (NSString *)getImageTitle;

@end

NS_ASSUME_NONNULL_END
