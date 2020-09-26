//
//  JXHomeTableViewCell.m
//  JXPhotoBrowser_Example
//
//  Created by Jason on 2020/9/6.
//  Copyright © 2020 JiongXing. All rights reserved.
//

#import "JXHomeTableViewCell.h"

@implementation JXHomeTableViewCell

+ (NSString *)defaultId
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

@end
