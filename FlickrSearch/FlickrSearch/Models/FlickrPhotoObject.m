//
//  FlickrPhotoObject.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrPhotoObject.h"

@implementation FlickrPhotoObject

- (FlickrPhotoObject *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.farm = [[dictionary valueForKey:@"farm"] stringValue];
        self.photoId = [dictionary valueForKey:@"id"];
        self.server = [dictionary valueForKey:@"server"];
        self.title = [dictionary valueForKey:@"title"];
        self.secret = [dictionary valueForKey:@"secret"];
    }
    return self;
}

@end
