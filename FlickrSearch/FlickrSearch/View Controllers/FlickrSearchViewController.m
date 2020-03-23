//
//  FlickrSearchCollectionViewController.m
//  FlickrSearch
//
//  Created by Richard Cordero on 3/22/20.
//  Copyright © 2020 Richard Cordero. All rights reserved.
//

#import "FlickrSearchViewController.h"
#import "FlickrPhotosListViewModel.h"
#import "FlickrDownloadManager.h"
#import "FlickrPhotoViewModel.h"
#import "FlickrPhotoCollectionViewCell.h"

@interface FlickrSearchViewController () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

// IB Outlets
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

// Misc. Properties
@property NSIndexPath *selectedIndexPath;
@property FlickrPhotosListViewModel *flickrPhotosListDataSource;
@property FlickrDownloadManager *downloadManager;
@property UIRefreshControl *refreshControl;

@end

@implementation FlickrSearchViewController

static NSString * const reuseIdentifier = @"FlickrPhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Stylize Nav Bar
    [self.navigationItem setTitle:@"Flickr Search"];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0 green:99/255.0 blue:220/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName : [UIFont systemFontOfSize:17.0f weight:UIFontWeightMedium]
                                                                      }];
    
    // Intitialize the Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFlickrSearch:) forControlEvents:UIControlEventValueChanged];
    self.collectionView.refreshControl = self.refreshControl;
    
    // Initialize Download Maanger
    self.downloadManager = [[FlickrDownloadManager alloc] init];
    
    // Initialize Flickr Photos List Data Source
    self.flickrPhotosListDataSource = [[FlickrPhotosListViewModel alloc] initWithDownloadManager:self.downloadManager];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // On orientation change, reload the visible items.
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    // If the search bar is not empty, trigger the Flickr Search download.
    [self.flickrPhotosListDataSource clear];
    [self.collectionView reloadData];
    if (searchBar.text && [searchBar.text isEqualToString:@""] == NO) {
        [self executeDownloadFlickrPhotosWithKeyword:self.searchBar.text];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.flickrPhotosListDataSource getFlickrPhotosList].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCollectionViewCell *cell = (FlickrPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    FlickrPhotoViewModel *flickrPhotoVM = [[self.flickrPhotosListDataSource getFlickrPhotosList] objectAtIndex:indexPath.row];

    // Set Title
    cell.imageTitleLabel.text = [flickrPhotoVM getImageTitle];
    
    // Set Image or Request Image
    UIImage *imageData = [flickrPhotoVM getImageData];
    [cell.imageView setImage:imageData];
    
    // Hide the Image Title if an Image is already present
    if (imageData) {
        [cell.imageTitleLabel setHidden:YES];
    } else {
        [cell.imageTitleLabel setHidden:NO];
    }
    [cell setNeedsLayout];
    [cell layoutSubviews];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    __block NSIndexPath *blockSafeIndexPath = indexPath;
    // If a cell is displayed on the screen, request the cell's image data if it has not been downloaded yet.
    FlickrPhotoViewModel *flickrPhotoVM = [[self.flickrPhotosListDataSource getFlickrPhotosList] objectAtIndex:indexPath.row];
    if ([flickrPhotoVM getImageData] == nil) {
        [flickrPhotoVM requestFlickrImageWithDownloadManager:self.downloadManager completionBlock:^(NSError * _Nullable error) {
            if (error == nil) {
                // If the download succeeded, assume the data source has been updated, so reload the cell.
                if ([self.collectionView cellForItemAtIndexPath:blockSafeIndexPath] != nil) {
                    [self.collectionView reloadItemsAtIndexPaths:@[blockSafeIndexPath]];
                }
            } else {
                // Handle error here if needed. Perhaps a retry function.
            }
        }];
    }
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Create square-shaped cells for a 3-column layout.
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat leftInset = flowLayout.sectionInset.left;
    CGFloat rightInset = flowLayout.sectionInset.right;
    NSInteger numOfColumns = 3;
    CGFloat interCellSpace = (numOfColumns - 1) * flowLayout.minimumLineSpacing; // Ex: If there are 3 columns, there'll be 2 columns of space between the cells.
    CGFloat viewForCellsWidth = self.collectionView.frame.size.width - leftInset - rightInset - interCellSpace;
    CGFloat cellWidth = floor(viewForCellsWidth / (CGFloat)numOfColumns);
    CGFloat cellHeight = cellWidth;
    
    return CGSizeMake(cellWidth, cellHeight);
}

#pragma mark <UICollectionViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // If the bottom of the list is reached, request the download of the next page.
    CGFloat bottomEdgeY = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdgeY >= scrollView.contentSize.height) {
        [self.flickrPhotosListDataSource downloadNextPage:^(NSError * _Nullable error) {
            if (error == nil) {
                [self.collectionView reloadData];
            }
        }];
    }
}

#pragma mark - Private methods

- (void)executeDownloadFlickrPhotosWithKeyword:(NSString *)keyword {
    // Resign Search bar focus
    [self.searchBar resignFirstResponder];
    
    // Manually animate the refresh control
    [self.refreshControl beginRefreshing];
    self.collectionView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    
    [self.flickrPhotosListDataSource downloadFlickrPhotosWithKeyword:keyword completionBlock:^(NSError * _Nullable error) {
        if (error == nil) {
            // Once the method finishes, reload the collection view.
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            // Prompt the user of the error.
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                     message:@"There was an unexpected error while searching. Please  try again."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)refreshFlickrSearch:(id)event {
    [self executeDownloadFlickrPhotosWithKeyword:self.searchBar.text];
}

@end
