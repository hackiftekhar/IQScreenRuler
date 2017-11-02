//
//  SRScreenshotCollectionViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRScreenshotCollectionViewController.h"
#import "SRScreenshotCollectionViewCell.h"
#import <Photos/Photos.h>
#import "UIFont+AppFont.h"
#import "UIColor+ThemeColor.h"
#import <Crashlytics/Answers.h>

@implementation UICollectionView(Screenshots)

- (NSArray<NSIndexPath *>*)indexPathsForElementsInRect:(CGRect)rect
{
    NSArray<UICollectionViewLayoutAttributes *> * allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray * indexPaths = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes * attributes in allLayoutAttributes)
    {
        [indexPaths addObject:attributes.indexPath];
    }
    
    return indexPaths;
}

@end


@interface SRScreenshotCollectionViewController ()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) IBOutlet UICollectionView *latestScreenshotCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhotoLibrary;
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;
@property (strong, nonatomic) IBOutlet UIButton *buttonCancel;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property CGFloat panBeginHeight;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) PHFetchResult * completeFetchResult;

@property (nonatomic, strong) PHCachingImageManager * imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;


@end

@implementation SRScreenshotCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tintColor = [UIColor originalThemeColor];
    
    [self.buttonPhotoLibrary setTitle:NSLocalizedString(@"photo_library", nil) forState:UIControlStateNormal];
    [self.buttonCamera setTitle:NSLocalizedString(@"camera", nil) forState:UIControlStateNormal];
    [self.buttonCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self.latestScreenshotCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];

    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
    
    PHAssetCollection *screenshotCollection = [smartAlbums firstObject];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    self.completeFetchResult = [PHAsset fetchAssetsInAssetCollection:screenshotCollection
                                                             options:options];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.latestScreenshotCollectionView reloadData];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (IBAction)panAction:(UIPanGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.panBeginHeight = self.collectionViewHeight.constant;
    }

    CGPoint translation = [sender translationInView:self.view];
    
    CGFloat newConstant = self.panBeginHeight - translation.y;
    
    newConstant = MAX(100, newConstant);
    newConstant = MIN(newConstant, self.view.safeAreaLayoutGuide.layoutFrame.size.height-200);
    self.collectionViewHeight.constant = newConstant;
    [self.visualEffectView setNeedsLayout];
    [self.visualEffectView layoutIfNeeded];
}


- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismissViewControllerCompletion:nil];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _tapGesture)
    {
        if (touch.view == self.view)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

- (NSArray *)indexPathsFromIndexSet:(NSIndexSet *)indexSet withSection:(int)section {
    if (indexSet == nil) {
        return nil;
    }
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    
    return indexPaths;
}

-(void)photoLibraryDidChange:(PHChange *)changeInstance
{
    PHFetchResultChangeDetails *changes = [changeInstance changeDetailsForFetchResult:self.completeFetchResult];
    
    if (changes)
    {
        __weak typeof(self) weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:weakSelf.completeFetchResult];
            if (collectionChanges) {
                
                weakSelf.completeFetchResult = [collectionChanges fetchResultAfterChanges];
                
                UICollectionView *collectionView = weakSelf.latestScreenshotCollectionView;
                NSArray *removedPaths;
                NSArray *insertedPaths;
                NSArray *changedPaths;
                
                if ([collectionChanges hasIncrementalChanges]) {
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    removedPaths = [weakSelf indexPathsFromIndexSet:removedIndexes withSection:0];
                    
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    insertedPaths = [weakSelf indexPathsFromIndexSet:insertedIndexes withSection:0];
                    
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    changedPaths = [weakSelf indexPathsFromIndexSet:changedIndexes withSection:0];
                    
                    BOOL shouldReload = NO;
                    
                    if (changedPaths != nil && removedPaths != nil) {
                        for (NSIndexPath *changedPath in changedPaths) {
                            if ([removedPaths containsObject:changedPath]) {
                                shouldReload = YES;
                                break;
                            }
                        }
                    }
                    
                    if (removedPaths.lastObject && ((NSIndexPath *)removedPaths.lastObject).item >= weakSelf.completeFetchResult.count) {
                        shouldReload = YES;
                    }
                    
                    if (shouldReload) {
                        [collectionView reloadData];
                        
                    } else {
                        [collectionView performBatchUpdates:^{
                            
                            [collectionView.collectionViewLayout invalidateLayout];
                            
                            if (removedPaths) {
                                [collectionView deleteItemsAtIndexPaths:removedPaths];
                            }
                            
                            if (insertedPaths) {
                                [collectionView insertItemsAtIndexPaths:insertedPaths];
                            }
                            
                            if (changedPaths) {
                                [collectionView reloadItemsAtIndexPaths:changedPaths];
                            }
                            
                            if ([collectionChanges hasMoves]) {
                                [collectionChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                                    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                                    [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                                }];
                            }
                            
                        } completion:^(BOOL finished) {
                        }];
                    }
                    
                    [weakSelf resetCachedAssets];
                } else {
                    [collectionView reloadData];
                }
            }
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.completeFetchResult.count == 0)
    {
        return CGSizeMake(collectionView.bounds.size.width-20, collectionView.bounds.size.height-20);
    }
    else
    {
        return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    view.backgroundColor = [UIColor clearColor];
    if (self.completeFetchResult.count == 0)
    {
        UILabel *label1 = [[UILabel alloc] initWithFrame:view.bounds];
        label1.adjustsFontSizeToFitWidth = YES;
        label1.minimumScaleFactor = 0.5;
        label1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            label1.font = [UIFont kohinoorBanglaSemiboldWithSize:40.0];
        }
        else
        {
            label1.font = [UIFont kohinoorBanglaSemiboldWithSize:25.0];
        }

        label1.numberOfLines = 0;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = [UIColor darkGrayColor];
        label1.text = NSLocalizedString(@"no_screenshots_title", nil);
        [view addSubview:label1];
    }
    return view;
}

- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.completeFetchResult.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRScreenshotCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SRScreenshotCollectionViewCell class]) forIndexPath:indexPath];

    [item.screenshotImageView setImage:nil];
    
    if (self.completeFetchResult.count > indexPath.row)
    {
        __weak SRScreenshotCollectionViewCell *blockItem = item;
        
        PHImageRequestOptions * options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = NO;
        
        [self.imageManager requestImageForAsset:self.completeFetchResult[indexPath.item]
                                     targetSize:CGSizeMake(80, 80)
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      
                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          blockItem.screenshotImageView.image = result;
                                      }];
                                  }];
    }
    
    return item;
}

#pragma mark - Preheating code for images

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    if ([self isViewLoaded] || self.view.window == nil)
    {
        return;
    }
    
    CGRect preheatRect = CGRectInset(self.view.bounds, 0, -0.5 * self.view.bounds.size.height);
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta <= self.view.bounds.size.height / 3)
    {
        return;
    }
    
    NSMutableArray<NSValue *>* addedRects = [NSMutableArray new];
    NSMutableArray<NSValue *>* removedRects = [NSMutableArray new];
    
    [self differencesBetweenRect:self.previousPreheatRect andRect:preheatRect addedArray:addedRects removedArray:removedRects];
    
    NSMutableArray<PHAsset *>* addedAssets = [NSMutableArray new];
    for (NSValue * rectValue in addedRects)
    {
        for (NSIndexPath * indexPath in [self.latestScreenshotCollectionView indexPathsForElementsInRect:[rectValue CGRectValue]])
        {
            [addedAssets addObject:self.completeFetchResult[indexPath.item]];
        }
    }
    
    NSMutableArray<PHAsset *>* removedAssets = [NSMutableArray new];
    for (NSValue * rectValue in removedRects)
    {
        for (NSIndexPath * indexPath in [self.latestScreenshotCollectionView indexPathsForElementsInRect:[rectValue CGRectValue]])
        {
            [removedAssets addObject:self.completeFetchResult[indexPath.item]];
        }
    }
    
    [self.imageManager startCachingImagesForAssets:addedAssets
                                                                       targetSize:CGSizeMake(200, 200)
                                                                      contentMode:PHImageContentModeAspectFill
                                                                          options:nil];
    
    [self.imageManager stopCachingImagesForAssets:removedAssets
                                                                      targetSize:CGSizeMake(200, 200)
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
    
    self.previousPreheatRect = preheatRect;
}

- (void)differencesBetweenRect:(CGRect)oldRect
                       andRect:(CGRect)newRect
                    addedArray:(NSMutableArray<NSValue *>*)added
                  removedArray:(NSMutableArray<NSValue *>*)removed
{
    if (CGRectIntersectsRect(oldRect, newRect))
    {
        if (CGRectGetMaxY(newRect) > CGRectGetMaxY(oldRect))
        {
            [added addObject:[NSValue valueWithCGRect:CGRectMake(newRect.origin.x, CGRectGetMaxY(oldRect),
                                                                 CGRectGetWidth(newRect), CGRectGetMaxY(newRect) - CGRectGetMaxY(oldRect))]];
        }
        if (CGRectGetMinY(oldRect) > CGRectGetMinY(newRect))
        {
            [added addObject:[NSValue valueWithCGRect:CGRectMake(newRect.origin.x, CGRectGetMinY(newRect),
                                                                 CGRectGetWidth(newRect), CGRectGetMinY(oldRect) - CGRectGetMinY(newRect))]];
        }
        
        if (CGRectGetMaxY(newRect) < CGRectGetMaxY(oldRect))
        {
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(newRect.origin.x, CGRectGetMaxY(newRect),
                                                                   CGRectGetWidth(newRect), CGRectGetMaxY(oldRect) - CGRectGetMaxY(newRect))]];
        }
        if (CGRectGetMinY(oldRect) < CGRectGetMinY(newRect))
        {
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(newRect.origin.x, CGRectGetMinY(oldRect),
                                                                   CGRectGetWidth(newRect), CGRectGetMinY(newRect) - CGRectGetMinY(oldRect))]];
        }
    }
    else
    {
        [added addObject:[NSValue valueWithCGRect:newRect]];
        [removed addObject:[NSValue valueWithCGRect:oldRect]];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [Answers logCustomEventWithName:@"Screenshot Selected" customAttributes:nil];

    __weak typeof(self) weakSelf = self;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor orangeColor];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        
        [weakSelf.imageManager requestImageForAsset:weakSelf.completeFetchResult[indexPath.item] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [activityIndicator removeFromSuperview];
                
                if (result == nil)
                {
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"image_load_error", nil) preferredStyle:UIAlertControllerStyleAlert];
                    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
                    controller.popoverPresentationController.sourceView = collectionView;
                    [weakSelf presentViewController:controller animated:YES completion:nil];
                }
                else
                {
                    if ([weakSelf.delegate respondsToSelector:@selector(screenshotController:didSelectScreenshot:)])
                    {
                        [weakSelf.delegate screenshotController:weakSelf didSelectScreenshot:result];
                    }
                    else
                    {
                        [weakSelf dismissViewControllerCompletion:nil];
                    }
                }
            }];
        }];
    }];
}

- (IBAction)photoLibraryAction:(UIButton *)sender {
    
    [Answers logCustomEventWithName:@"Open Photo Library" customAttributes:nil];

    if ([self.delegate respondsToSelector:@selector(screenshotControllerDidSelectOpenPhotoLibrary:)])
    {
        [self.delegate screenshotControllerDidSelectOpenPhotoLibrary:self];
    }
    else
    {
        [self dismissViewControllerCompletion:nil];
    }
}

- (IBAction)openCameraAction:(UIButton *)sender {
    
    [Answers logCustomEventWithName:@"Open Camera" customAttributes:nil];

    if ([self.delegate respondsToSelector:@selector(screenshotControllerDidSelectOpenCamera:)])
    {
        [self.delegate screenshotControllerDidSelectOpenCamera:self];
    }
    else
    {
        [self dismissViewControllerCompletion:nil];
    }
}

- (IBAction)cancelAction:(UIButton *)sender
{
    [self dismissViewControllerCompletion:nil];
}

-(void)presentOverViewController:(UIViewController*)controller completion:(void (^)(void))completion
{
    [controller addChildViewController:self];
    self.view.frame = controller.view.bounds;
    [controller.view addSubview:self.view];
    [self didMoveToParentViewController:controller];
    
    __weak typeof(self) weakSelf = self;

    self.view.backgroundColor = [UIColor clearColor];
    self.visualEffectView.transform = CGAffineTransformMakeTranslation(0, self.visualEffectView.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0 options:7<<16|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        weakSelf.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        weakSelf.visualEffectView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion)
        {
            completion();
        }
    }];
}

-(void)dismissViewControllerCompletion:(void (^)(void))completion
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.visualEffectView.transform = CGAffineTransformIdentity;

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
        weakSelf.view.backgroundColor = [UIColor clearColor];
        weakSelf.visualEffectView.transform = CGAffineTransformMakeTranslation(0, weakSelf.visualEffectView.frame.size.height);
    } completion:^(BOOL finished) {
        [weakSelf willMoveToParentViewController:nil];
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
        
        if (completion)
        {
            completion();
        }
    }];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) weakSelf = self;

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [weakSelf.latestScreenshotCollectionView.collectionViewLayout invalidateLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}


@end


