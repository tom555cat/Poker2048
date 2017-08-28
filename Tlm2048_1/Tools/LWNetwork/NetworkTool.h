//
//  NetworkTool.h
//  CashLoan
//
//  Created by user on 16/8/31.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import <Foundation/Foundation.h>

enum HTTPMETHOD{
    
    METHOD_GET   = 0,    //GET请求
    METHOD_POST  = 1,    //POST请求
};

@interface NetworkTool : NSObject

/**
 *JSON方式获取数据
 *urlStr:获取数据的url地址
 *
 */
+(void)requestAFURL:(NSString *)URLString
         httpMethod:(NSInteger)method
         parameters:(id)parameters
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;

+(void)requestNoActivityAFURL:(NSString *)URLString  parameters:(id)parameters succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure;

+(void)requestNOActivityAFURL:(NSString *)URLString
         httpMethod:(NSInteger)method
         parameters:(id)parameters
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure;
//下载文件
+ (void)sessionDownloadWithUrl:(NSString *)urlStr success:(void (^)(NSURL *fileURL))success fail:(void (^)())fail;

//上传文件
+ (void)postUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(void (^)(id responseObject))success fail:(void (^)())fail;

+(void)upLoadWithUrl:(NSString *)urlStr data:(NSData *)data dataName:(NSString *)name  fileType:(NSString *)fileType success:(void (^)(id responseObject))success fail:(void (^)())fail;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
