//
//  FSHTTPSessionManager.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSHTTPSessionManager : AFHTTPSessionManager

#pragma mark - Methods
+ (instancetype)sharedFlickrJSONAPIClient;

@end

NS_ASSUME_NONNULL_END
