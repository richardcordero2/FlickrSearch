//
//  FlickrPhotoCollectionViewCell.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrPhotoCollectionViewCell.h"

@implementation FlickrPhotoCollectionViewCell

- (UIImageView *)imageView {
    if (!_imageView) {
       _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
       [self.contentView addSubview:_imageView];
    } else {
        _imageView.frame = self.contentView.bounds;
    }
    return _imageView;
}

@end
