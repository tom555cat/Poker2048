//
//  UIColor+Extension.h
//  IMLottery
//
//  Created by feng-Mac on 16/8/17.
//  Copyright © 2016年 feng-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (UIColor *)randomColor;
+ (UIColor *)colorWithR:(int)R G:(int)G B:(int)B andAlpha:(CGFloat)alpha;

@end
