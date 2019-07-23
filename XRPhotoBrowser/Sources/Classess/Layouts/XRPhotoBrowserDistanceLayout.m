//
//  XRPhotoBrowserDistanceLayout.m
//  XRPhotoBrowser
//
//  Created by 徐冉 on 2019/7/15.
//  Copyright © 2019 QK. All rights reserved.
//

#import "XRPhotoBrowserDistanceLayout.h"

@implementation XRPhotoBrowserDistanceLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.distanceOfPage = 12;
        return self;
    }
    
    return nil;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = self.collectionView.bounds.size;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray <UICollectionViewLayoutAttributes *>* layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    NSArray <UICollectionViewLayoutAttributes *>* copyLayoutAttributes = [[NSArray alloc] initWithArray:layoutAttributes copyItems:YES];
    
    CGFloat halfWidth = self.collectionView.bounds.size.width / 2.0;
    CGFloat centerX = self.collectionView.contentOffset.x + halfWidth;
    
    [copyLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(obj.center.x + (obj.center.x - centerX) / halfWidth * self.distanceOfPage / 2.0, obj.center.y);
    }];
    
    return copyLayoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
