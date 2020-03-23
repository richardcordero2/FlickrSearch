//
//  FSHTTPSessionManager.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FSHTTPSessionManager.h"

@implementation FSHTTPSessionManager

static FSHTTPSessionManager *sharedJSONClient;

+ (instancetype)sharedFlickrJSONAPIClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedJSONClient = [[FSHTTPSessionManager alloc] initForJSONWithBaseURL:[NSURL URLWithString:@"https://api.flickr.com/"]];
        sharedJSONClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return sharedJSONClient;
}

- (instancetype)initForJSONWithBaseURL:(NSURL *)url {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    self = [super initWithBaseURL:url sessionConfiguration:sessionConfig];
    
    // Modify sessionConfig here for specific configurations. No changes needed for now.
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

@end
