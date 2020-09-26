//
//  JXHomeActionModel.h
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/6.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXHomeActionModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) void (^clickCallback)(void);

@end

NS_ASSUME_NONNULL_END
