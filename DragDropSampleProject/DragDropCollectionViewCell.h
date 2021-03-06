//
//  DragDropCollectionViewCell.h
//  DrapDropTest
//
//  Created by Bryn Bodayle on 2/2/14.
//  Copyright (c) 2014 Bryn Bodayle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragDropCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign, getter = isHoldingObject) BOOL holdingObject;
@property (nonatomic, strong) UIGestureRecognizer *dragDropGestureRecognizer;

@end
