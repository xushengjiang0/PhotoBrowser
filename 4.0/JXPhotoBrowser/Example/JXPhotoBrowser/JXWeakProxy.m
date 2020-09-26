//
//  JXWeakProxy.m
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/26.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import "JXWeakProxy.h"

@implementation JXWeakProxy

+ (instancetype)proxyWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self.target respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.target];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.target methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.target respondsToSelector:aSelector];
}

@end
