//
//  FlickrPhoto.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrPhotoViewModel.h"
#import "FlickrPhotoObject.h"
#import "FlickrDownloadManager.h"

@interface FlickrPhotoViewModel ()

@property UIImage *imageData;
@property NSString *imageTitle;

@end

@implementation FlickrPhotoViewModel

- (FlickrPhotoViewModel *)initWithFlickrPhotoObject:(FlickrPhotoObject *)flickrPhotoObject {
    self = [super init];
    if (self) {
        self.flickrPhotoObject = flickrPhotoObject;
        self.imageTitle = flickrPhotoObject.title;
    }
    return self;
}

// The method to handle the single downloading of the image data.
- (void)requestFlickrImageWithDownloadManager:(FlickrDownloadManager *)downloadManager completionBlock:(CompletionBlock)completionBlock {
    [downloadManager downloadFlickrPhotoWithFarm:self.flickrPhotoObject.farm server:self.flickrPhotoObject.server photoId:self.flickrPhotoObject.photoId secret:self.flickrPhotoObject.secret completionBlock:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (error == nil) {
            if (image) {
                self.imageData = image;
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

- (UIImage *)getImageData {
    return self.imageData;
}

- (NSString *)getImageTitle {
    return self.imageTitle;
}

@end
