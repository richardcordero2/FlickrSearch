//
//  FlickrPhotoCollectionViewCell.h
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhotoCollectionViewCell : UICollectionViewCell

#pragma mark - Properties
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *imageTitleLabel;

@end

NS_ASSUME_NONNULL_END
