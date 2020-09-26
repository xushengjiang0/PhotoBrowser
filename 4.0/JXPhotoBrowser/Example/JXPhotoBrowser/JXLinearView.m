//
//  JXLinearView.m
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import "JXLinearView.h"

@interface JXLinearView ()

/// 缓存复用 Cell 的 identifier
@property (nonatomic, copy) NSString *defaultReuseId;

@end

@implementation JXLinearView

#pragma mark - Public

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    self.defaultReuseId = identifier;
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index
{
    NSIndexPath *idxPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:idxPath];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:animated scrollPosition:scrollPosition];
}

- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:animated];
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.itemLength = 80.f;
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}


#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInLinearView:)])
    {
        return [self.dataSource numberOfItemsInLinearView:self];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 若实现了`dequeueReusableCellWithReuseIdentifier:forIndex:`，优先调用
    if ([self.dataSource respondsToSelector:@selector(linearView:cellForItemAtIndex:)])
    {
        return [self.dataSource linearView:self cellForItemAtIndex:indexPath.item];
    }
    // 否则，自动取复用Cell
    NSAssert(self.defaultReuseId, @"请注册可复用的Cell，或实现`linearView:cellForItemAtIndex:`协议方法");
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.defaultReuseId forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(reuseCell:atIndex:)])
    {
        [self.delegate reuseCell:cell atIndex:indexPath.item];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat length = self.itemLength;
    if ([self.delegate respondsToSelector:@selector(linearView:lengthForItemAtIndex:)])
    {
        length = [self.delegate linearView:self lengthForItemAtIndex:indexPath.item];
    }
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        CGFloat height = collectionView.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
        return CGSizeMake(length, height);
    }
    else
    {
        CGFloat width = collectionView.bounds.size.width - self.edgeInsets.left - self.edgeInsets.right;
        return CGSizeMake(width, length);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.itemSpacing;
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(linearView:didSelectItemAtIndex:cell:)])
    {
        [self.delegate linearView:self
           didSelectItemAtIndex:indexPath.item
                           cell:[collectionView cellForItemAtIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(linearView:willDisplayCell:atIndex:)])
    {
        [self.delegate linearView:self willDisplayCell:cell atIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(linearView:didEndDisplayingCell:atIndex:)])
    {
        [self.delegate linearView:self didEndDisplayingCell:cell atIndex:indexPath.item];
    }
}

#pragma mark - ScorllViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(linearViewDidScroll:)])
    {
        [self.delegate linearViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(linearViewWillBeginDragging:)])
    {
        [self.delegate linearViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.delegate respondsToSelector:@selector(linearViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.delegate linearViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(linearViewDidEndDragging:willDecelerate:)])
    {
        [self.delegate linearViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(linearViewDidEndDecelerating:)])
    {
        [self.delegate linearViewDidEndDecelerating:self];
    }
}

#pragma mark Getters & Setters

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout)
    {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0.f;
        _flowLayout.minimumInteritemSpacing = 0.f;
        // 默认值
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.backgroundView.backgroundColor = UIColor.clearColor;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *))
        {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        // 默认值
        _collectionView.bounces = YES;
        _collectionView.pagingEnabled = NO;
    }
    return _collectionView;
}

- (UICollectionViewScrollDirection)scrollDirection
{
    return self.flowLayout.scrollDirection;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)direction
{
    self.flowLayout.scrollDirection = direction;
}

- (UIEdgeInsets)edgeInsets
{
    return self.flowLayout.sectionInset;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    self.flowLayout.sectionInset = edgeInsets;
}

- (BOOL)bounces
{
    return self.collectionView.bounces;
}

- (void)setBounces:(BOOL)bounces
{
    self.collectionView.bounces = bounces;
}

- (BOOL)pagingEnabled
{
    return self.collectionView.pagingEnabled;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    self.collectionView.pagingEnabled = pagingEnabled;
}

@end
