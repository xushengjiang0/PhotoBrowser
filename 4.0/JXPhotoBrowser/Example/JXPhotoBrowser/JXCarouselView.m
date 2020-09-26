//
//  JXCarouselView.m
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import "JXCarouselView.h"
#import "JXWeakProxy.h"

@interface JXCarouselView ()

/// 页码器
@property (nonatomic, strong) UIPageControl *pageControl;

/// 真实内容数量，从dataSource获取而暂存
@property (nonatomic, assign) NSInteger numberOfItems;

/// CollectionView显示中的index。包含扩展的首末位
@property (nonatomic, assign) NSInteger carouselIndex;

/// 定时器
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation JXCarouselView

- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.timeInterval = 5.f;
        self.showPageControl = YES;
        self.autoScrollEnable = YES;
        self.singleItemCheck = YES;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.bounces = NO;
        self.pagingEnabled = YES;
        self.carouselIndex = -1;
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.itemLength = self.bounds.size.width;
    
    // 初始化，只调用一次。ColectionView移动到数据源第一张图位置
    if (self.carouselIndex == -1 && self.numberOfItems > 0)
    {
        self.carouselIndex = 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)resumeAutoScroll
{
    if (self.carouselIndex < [self.collectionView numberOfItemsInSection:0])
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.carouselIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    [self startTimerIfNeeded];
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}

- (void)pauseAutoScroll
{
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (NSInteger)currentIndex
{
    return [self contentIndexForCarouselIndex:self.carouselIndex];
}

#pragma mark - Private

- (void)reloadPageControl
{
    self.pageControl.hidden = (self.showPageControl && self.numberOfItems > 1) ? NO : YES;
    self.pageControl.numberOfPages = self.numberOfItems;
    self.pageControl.currentPage = self.currentIndex;
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 30,
                                        self.bounds.size.width, 30);
}

/// 把要显示的indexPath转换成对应真实内容的index
- (NSInteger)contentIndexForCarouselIndex:(NSInteger)index
{
    if (self.numberOfItems <= 0)
    {
        return 0;
    }
    if (index == 0)
    {
        // 扩展首位，对应真实内容最后一个元素
        return self.numberOfItems - 1;
    }
    if (index == self.numberOfItems + 1)
    {
        // 扩展末位，对应真实内容首元素
        return 0;
    }
    // 因在首位插了扩展位，故显示元素比真实元素后偏了一位。减1即对应真实元素位
    return index - 1;
}

/// 在滑到了首末位的时候，调整以实现循环
- (void)adjustCarouselIndex
{
    CGFloat width = self.collectionView.bounds.size.width;
    CGPoint offset = self.collectionView.contentOffset;
    if (self.carouselIndex == 0)
    {
        // 已到达首位，移动到倒数第二位
        offset.x += self.numberOfItems * width;
        self.carouselIndex = self.numberOfItems;
        self.collectionView.contentOffset = offset;
    }
    else if (self.carouselIndex == self.numberOfItems + 1)
    {
        // 已到达末位，移动到顺数第二位
        offset.x -= self.numberOfItems * width;
        self.carouselIndex = 1;
        self.collectionView.contentOffset = offset;
    }
    self.pageControl.currentPage = self.currentIndex;
}

- (void)startTimerIfNeeded
{
    if (self.numberOfItems <= 0)
    {
        return;
    }
    if (!self.timer)
    {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:[JXWeakProxy proxyWithTarget:self] selector:@selector(timerTask) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.timer = timer;
    }
}

- (void)timerTask
{
    if (self.numberOfItems <= 0)
    {
        return;
    }
    if (self.numberOfItems == 1 && self.singleItemCheck)
    {
        return;
    }
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger targetIndex = self.carouselIndex + 1;
    NSInteger maxIndex = cellCount - 1;
    if (targetIndex > maxIndex)
    {
        targetIndex = maxIndex;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:targetIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.numberOfItems = [super collectionView:collectionView numberOfItemsInSection:section];
    self.collectionView.scrollEnabled = (self.singleItemCheck && self.numberOfItems <= 1) ? NO : YES;
    [self reloadPageControl];
    if (self.autoScrollEnable)
    {
        [self startTimerIfNeeded];
    }
    if (self.numberOfItems > 0)
    {
        return self.numberOfItems + 2;
    }
    self.carouselIndex = 0;
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [self contentIndexForCarouselIndex:indexPath.item];
    NSIndexPath *contentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [super collectionView:collectionView cellForItemAtIndexPath:contentIndexPath];
}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger index = [self contentIndexForCarouselIndex:indexPath.item];
    NSIndexPath *contentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [super collectionView:collectionView didSelectItemAtIndexPath:contentIndexPath];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    NSInteger index = (NSInteger)round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if (index != self.carouselIndex)
    {
        self.carouselIndex = index;
        [self adjustCarouselIndex];
        if (self.didScrollToIndex)
        {
            self.didScrollToIndex(self.currentIndex);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [super scrollViewWillBeginDragging:scrollView];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

- (void)setShowPageControl:(BOOL)pageControlEnable
{
    _showPageControl = pageControlEnable;
    if (NO == pageControlEnable)
    {
        self.pageControl.hidden = YES;
    }
}

@end
