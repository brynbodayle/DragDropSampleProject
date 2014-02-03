//
//  DragDropCollectionViewCell.m
//  DrapDropTest
//
//  Created by Bryn Bodayle on 2/2/14.
//  Copyright (c) 2014 Bryn Bodayle. All rights reserved.
//

#import "DragDropCollectionViewCell.h"

@implementation DragDropCollectionViewCell

- (void)setHoldingObject:(BOOL)holdingObject {
    
    self.backgroundColor = holdingObject ? [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.000] : [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1.000];
    
    _holdingObject = holdingObject;
}

@end
