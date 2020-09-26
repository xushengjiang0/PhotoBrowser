//
//  JXCarouselView.h
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXLinearView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXCarouselView : JXLinearView

/// 自动轮播的间隔，单位：秒。默认值：5
@property (nonatomic, assign) NSTimeInterval timeInterval;

/// 是否启用PageControl，默认启用：YES
@property (nonatomic, assign) BOOL showPageControl;

/// 是否启用自动轮播。默认值：YES
@property (nonatomic, assign) BOOL autoScrollEnable;

/// 检查是否只有一项数据，当只有一项数据时禁止滑动。YES：开启检查；NO：不检查
@property (nonatomic, assign) BOOL singleItemCheck;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

/// 页切换时回调
@property (nonatomic, copy) void (^didScrollToIndex)(NSInteger index);

/// 恢复自动轮播
- (void)resumeAutoScroll;

/// 暂停自动轮播
- (void)pauseAutoScroll;

@end

NS_ASSUME_NONNULL_END
