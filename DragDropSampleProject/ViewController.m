//
//  ViewController.m
//  DrapDropTest
//
//  Created by Bryn Bodayle on 2/2/14.
//  Copyright (c) 2014 Bryn Bodayle. All rights reserved.
//

#define ANIMATION_DURATION      0.15
#define MINIMUM_PRESS_DURATION  0.2

//view controllers
#import "ViewController.h"

//views
#import "DragDropCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, OBOvumSource, OBDropZone>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *items;

@end

NSString *const DragDropCollectionViewCellIdentifier = @"DragDropCollectionViewCellIdentifier";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = @[@NO, @NO, @NO, @NO, @YES, @NO, @NO, @NO, @NO, @NO, @NO, @NO];
	
    self.collectionView.contentInset = UIEdgeInsetsMake(125, 100, 100, 100);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[DragDropCollectionViewCell class] forCellWithReuseIdentifier:DragDropCollectionViewCellIdentifier];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(150, 150);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 50;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 50;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DragDropCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DragDropCollectionViewCellIdentifier forIndexPath:indexPath];
    
    BOOL item = [self.items[indexPath.row] boolValue];
    
    cell.holdingObject = item;
    
    if(item) {
        
        OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
        
        UILongPressGestureRecognizer *dragDropRecognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
        dragDropRecognizer.minimumPressDuration = MINIMUM_PRESS_DURATION;
        [cell addGestureRecognizer:dragDropRecognizer];
        cell.dragDropGestureRecognizer = dragDropRecognizer;
        cell.dropZoneHandler = nil;
    }
    else {
        
        cell.dropZoneHandler = self;
        [cell removeGestureRecognizer:cell.dragDropGestureRecognizer];
    }
    
    return cell;
}

#pragma mark - OBOvumSource

- (void)ovumDragWillBegin:(OBOvum*)ovum {
    
    NSIndexPath *indexPath = ovum.dataObject;
    DragDropCollectionViewCell *cell = (DragDropCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    cell.holdingObject = NO;
}

- (void)handleReturningToSourceAnimationForOvum:(OBOvum*)ovum completion:(void (^)(void))completion {
    
    NSIndexPath *indexPath = ovum.dataObject;
    
    DragDropCollectionViewCell *cell = (DragDropCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *dragView = ovum.dragView;

    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
        
        dragView.center = ovum.dragViewInitialCenter;
        dragView.transform = CGAffineTransformIdentity;
        
    }                 completion:^(BOOL finished) {
        
        cell.holdingObject = YES;
        completion();
    }];
}

- (OBOvum *)createOvumFromView:(UIView*)sourceView {
    
    UICollectionViewCell *cell = (UICollectionViewCell*)sourceView;
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = [self.collectionView indexPathForCell:cell];
    
    CGPoint touchLocation = [OBDragDropManager sharedManager].currentLocationInOverlayWindow;
    CGPoint viewLocation = sourceView.center;

    ovum.isCentered = NO;
    ovum.offsetOvumAndTouch = CGPointMake(touchLocation.x - viewLocation.x, touchLocation.y - viewLocation.y);

    return ovum;
}

- (UIView *)createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window {
    
    CGRect frame = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
    frame = [window convertRect:frame fromWindow:sourceView.window];
    
    UIView *dragView = [[UIView alloc] initWithFrame:frame];
    dragView.backgroundColor = sourceView.backgroundColor;
    return dragView;
}

- (void)dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location {
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        
        dragView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }
            completion:^(BOOL finished) {
        
    }];

}

#pragma mark - OBDropZone

- (void)ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    
    UIView *dragView = ovum.dragView;
    
    CGRect frame = [ovum.currentDropHandlingView convertRect:ovum.currentDropHandlingView.bounds toView:dragView.window];
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        
        dragView.frame = frame;
        
    }
                     completion:^(BOOL finished) {
                         
         DragDropCollectionViewCell *dropCell = (DragDropCollectionViewCell*)view;
         dropCell.holdingObject = YES;
         NSIndexPath *dropIndexPath = [self.collectionView indexPathForCell:dropCell];
         
         NSIndexPath *dragIndexPath = (NSIndexPath*)ovum.dataObject;
                         
         NSMutableArray *items = [self.items mutableCopy];
         [items exchangeObjectAtIndex:dropIndexPath.row withObjectAtIndex:dragIndexPath.row];
         self.items = items;
         
         [self.collectionView reloadItemsAtIndexPaths:@[dropIndexPath, dragIndexPath]];

         [dragView removeFromSuperview];
    }];

}

- (OBDropAction)ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        
        ovum.dragView.transform = CGAffineTransformIdentity;
        
    }                 completion:^(BOOL finished) {
        
    }];
    
    return OBDropActionMove;
}


- (void)ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^(void) {
        
        ovum.dragView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }
                     completion:^(BOOL finished) {
                         
    }];
}

- (void)handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager {
    //do nothing
}

@end
