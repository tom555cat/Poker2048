//
//  XCHostUtil.m
//  Poker2048
//
//  Created by tongleiming on 2019/6/4.
//  Copyright © 2019 tom555cat. All rights reserved.
//

#import "XCHostUtil.h"
#import "NSString+addition.h"
#import <netdb.h>
#import <arpa/inet.h>

@implementation XCHostUtil

+ (void)getIPv4AddressFromHost:(NSString *)host completion:(void (^)(NSString *address))completion {
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSString *ipAddress = [[self class] getIpv4AddressFromHost:host];
        if (![ipAddress xc_isIPv4Address]) {
            ipAddress = @"";
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(ipAddress);
            });
        }
    });
}

+ (NSString *)getIpv4AddressFromHost:(NSString *)host {
    const char *hostName = host.UTF8String;
    struct hostent *phost = [self getHostByName:hostName];
    // 域名查询为空，直接返回
    if ( phost == NULL ) { return nil; }
    
    // ip地址列表为空，直接返回
    char **pptr = phost->h_addr_list;
    if (*pptr == NULL) { return nil; }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phost->h_addr_list[0], 4);
    
    char ip[20] = { 0 };
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    return [NSString stringWithUTF8String:ip];
}

+ (struct hostent *)getHostByName: (const char *)hostName {
    __block struct hostent *phost = NULL;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock: ^{
        phost = gethostbyname(hostName);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC));
    [queue cancelAllOperations];
    return phost;
}


@end
