//
//  NSArray+Extension.m
//  https://github.com/JadynSky/TTWithoutUnicode
//
//  Created by WuZhongTian  on 16/1/9.
//  Copyright (c) 2016年 WuZhongTian. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)



-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *msr = [NSMutableString string];
    [msr appendString:@"["];
    for (id obj in self) {
        [msr appendFormat:@"\n\t%@,",obj];
    }
    //去掉最后一个逗号（,）
    if ([msr hasSuffix:@","]) {
        NSString *str = [msr substringToIndex:msr.length - 1];
        msr = [NSMutableString stringWithString:str];
    }
    [msr appendString:@"\n]"];
    return msr;
}


@end
