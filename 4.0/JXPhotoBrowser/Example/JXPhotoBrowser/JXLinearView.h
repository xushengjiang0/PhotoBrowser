//
//  JXLinearView.h
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JXLinearView;

@protocol JXLinearViewDataSource <NSObject>

@required

/// 总共有多少项
- (NSInteger)numberOfItemsInLinearView:(JXLinearView *)linearView;

@optional

/// 取单项视图。可选实现。
/// 若实现了本方法后，`reuseCell:atIndex:`将不会被调用。
- (__kindof UICollectionViewCell *)linearView:(JXLinearView *)linearView cellForItemAtIndex:(NSInteger)index;

@end

#pragma mark -

@protocol JXLinearViewDelegate <NSObject>

@optional

/// 取项长度。
/// 若没实现本方法，将取itemSize属性值，若itemSize属性值为Zero，则取estimatedItemSize
- (CGFloat)linearView:(JXLinearView *)linearView lengthForItemAtIndex:(NSInteger)index;

/// 复用 Cell 时回调
- (void)reuseCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;

/// 选中某项回调
- (void)linearView:(JXLinearView *)linearView didSelectItemAtIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;

- (void)linearView:(JXLinearView *)linearView willDisplayCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;

- (void)linearView:(JXLinearView *)linearView didEndDisplayingCell:(UICollectionViewCell *)cell atIndex:(NSInteger)index;

- (void)linearViewDidScroll:(JXLinearView *)linearView;

- (void)linearViewWillBeginDragging:(JXLinearView *)linearView;

- (void)linearViewWillEndDragging:(JXLinearView *)linearView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

- (void)linearViewDidEndDragging:(JXLinearView *)linearView willDecelerate:(BOOL)decelerate;

- (void)linearViewDidEndDecelerating:(JXLinearView *)linearView;

@end

#pragma mark -

@interface JXLinearView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/// 数据源
@property (nonatomic, weak) id<JXLinearViewDataSource> dataSource;

/// 事件代理
@property (nonatomic, weak) id<JXLinearViewDelegate> delegate;

/// 滚动方向，默认值：水平
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/// 内容外边距，默认值：Zero
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/// 项间距，默认值：0
@property (nonatomic, assign) CGFloat itemSpacing;

/// 边缘弹性，默认值：YES
@property (nonatomic, assign) BOOL bounces;

/// 项长度固定值。默认值：80.0。
/// 在不实现`linearView:lengthForItemAtIndex:`协议方法的时候，将直接使用此值以决定项空间
@property (nonatomic, assign) CGFloat itemLength;

/// 页式浏览
@property (nonatomic, assign) BOOL pagingEnabled;

/// 容器
@property (nonatomic, strong) UICollectionView *collectionView;

/// 布局
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

/// 注册复用 Cell，必须是 UICollectionViewCell 及其子类。
/// 第一次调用本方法时，传入的 cellClass 和 identifier 将被保存以作为默认复用 Cell。
/// 使用本方法注册 cellClass 后，可不实现`linearView:cellForItemAtIndex:`协议方法，
/// 可直接在`reuseCell:atIndex:`协议方法中获得复用的 Cell。
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/// 取复用Cell
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

/// 选中某项
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

/// 反选某项
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 刷新，重新加载数据
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
