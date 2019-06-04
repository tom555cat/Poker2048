//
//  XCHostUtil.h
//  Poker2048
//
//  Created by tongleiming on 2019/6/4.
//  Copyright © 2019 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCHostUtil : NSObject

+ (void)getIPv4AddressFromHost:(NSString *)host completion:(void (^)(NSString *address))completion;

@end

NS_ASSUME_NONNULL_END
