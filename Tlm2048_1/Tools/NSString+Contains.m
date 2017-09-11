//
//  NSString+Contains.m
//  TicketPrice
//
//  Created by HanLiu on 15/12/13.
//  Copyright © 2015年 WPW. All rights reserved.
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

- (BOOL)containsString:(NSString *)str
{
    if (nil == str) {
        return NO;
    }
    NSRange foundObj=[self rangeOfString:str options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

@end
