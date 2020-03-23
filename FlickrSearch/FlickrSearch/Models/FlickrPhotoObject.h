//
//  FlickrPhotoObject.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhotoObject : NSObject

#pragma mark - Properties
@property NSString *farm;
@property NSString *server;
@property NSString *photoId;
@property NSString *title;
@property NSString *secret;

#pragma mark - Methods
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
