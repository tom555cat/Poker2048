//
//  NSString+addition.m
//  Poker2048
//
//  Created by tongleiming on 2019/6/4.
//  Copyright © 2019 tom555cat. All rights reserved.
//

#import "NSString+addition.h"
#include <arpa/inet.h>

@implementation NSString (addition)

- (BOOL)xc_isIPv4Address
{
    if (self.length <= 0) {
        return NO;
    }
    
    const char *ip = [self UTF8String];
    int success = 0;
    struct in_addr addr;
    success = inet_pton(AF_INET, ip, &addr);
    
    return (success == 1);
}

@end
