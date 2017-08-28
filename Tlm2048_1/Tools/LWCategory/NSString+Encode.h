//
//  NSString+Encode.h
//  carcareIOS
//
//  Created by ileo on 16/7/25.
//  Copyright © 2016年 chezheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

//md5加密
-(NSString *)encodeWithMD5;

//URI编码
-(NSString *)encodeWithURIComponent;


//  适用于安卓iOS  资料来源： http://www.jianshu.com/p/df828a57cb8f
-(NSString *)encryptAESWithKey:(NSString *)key iv:(NSString *)iv;//aes加密
-(NSString *)decryptAESWithKey:(NSString *)key iv:(NSString *)iv;//aes解密


@end
