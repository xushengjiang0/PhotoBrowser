//
//  JXWeakProxy.h
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXWeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

+ (instancetype)proxyWithTarget:(id)target;

- (instancetype)initWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
