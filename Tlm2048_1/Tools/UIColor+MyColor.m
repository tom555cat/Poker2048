//
//  UIColor+MyColor.m
//  ShunFengDaiJia
//
//  Created by 顺风代驾 on 13-10-21.
//  Copyright (c) 2013年 yytmzys. All rights reserved.
//

#import "UIColor+MyColor.h"

@implementation UIColor (MyColor)

/**
 *	@brief	获取颜色对象
 *
 *	@param 	string 	颜色描述字符串，带“＃”开头 或者 "0X"
 *
 *	@return	颜色对象
 */
+ (UIColor *)myColorWithString:(NSString *)string
{
    NSString *cString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    NSScanner *scanner;
    scanner = [[NSScanner alloc] initWithString:rString];
    [scanner scanHexInt:&r];
    
    scanner = [[NSScanner alloc] initWithString:gString];
    [scanner scanHexInt:&g];

    scanner = [[NSScanner alloc] initWithString:bString];

    [scanner scanHexInt:&b];
    
    UIColor *resultColor = [[UIColor alloc] initWithRed:((float) r / 255.0f)
                                                  green:((float) g / 255.0f)
                                                   blue:((float) b / 255.0f)
                                                  alpha:1.0f];
    return resultColor;
}

/**
 *	@brief	获取颜色对象
 *
 *	@param 	string 	颜色描述字符串，带“＃”开头 或者 "0X"
 *
 *	@return	颜色对象
 */
+ (UIColor *)myColorWithString:(NSString *)string alpha:(CGFloat)alpha
{
    NSString *cString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    NSScanner *scanner;
    scanner = [[NSScanner alloc] initWithString:rString];
    [scanner scanHexInt:&r];
    
    scanner = [[NSScanner alloc] initWithString:gString];
    [scanner scanHexInt:&g];
    
    scanner = [[NSScanner alloc] initWithString:bString];
    
    [scanner scanHexInt:&b];
    
    UIColor *resultColor = [[UIColor alloc] initWithRed:((float) r / 255.0f)
                                                  green:((float) g / 255.0f)
                                                   blue:((float) b / 255.0f)
                                                  alpha:alpha];
    return resultColor;
}


@end
