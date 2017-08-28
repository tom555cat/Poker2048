//
//  NetworkTool.m
//  CashLoan
//
//  Created by user on 16/8/31.
//  Copyright © 2016年 user. All rights reserved.
//

#import "NetworkTool.h"
#import "MyToast.h"
#import "ActivityView.h"


@implementation NetworkTool

+(void)requestAFURL:(NSString *)URLString
         httpMethod:(NSInteger)method
         parameters:(id)parameters
            succeed:(void (^)(id))succeed
            failure:(void (^)(NSError *))failure
{
    // 0.设置API地址
    
    URLString=[NetworkTool newUrlStr:URLString];
    
    [[ActivityView shareAcctivity]showActivity];
    // 1.创建请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 2.申明返回的结果是二进制类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.如果报接受类型不一致请替换一致text/html  或者 text/plain
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    // 4.请求超时，时间设置
    manager.requestSerializer.timeoutInterval =130;
    
    if (parameters==nil) {
        parameters = @{@"appid":APPID};
    }
    else
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:parameters];

        parameters=dic;
    }
    
    // 5.选择请求方式 GET 或 POST
    switch (method) {
        case METHOD_GET:
        {
            [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSString *responseStr =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"responseStr--%@",responseStr);
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed([NetworkTool dictionaryWithJsonString:responseStr]);
                    [[ActivityView shareAcctivity]hiddeActivity];
                });
                
                
               
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [[ActivityView shareAcctivity]hiddeActivity];
                failure(error);
                
                
                
            }];
        }
            break;
            
        case METHOD_POST:
        {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSString *responseStr =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSDictionary *dic=[NetworkTool dictionaryWithJsonString:responseStr];
                
                NSLog(@"tongyongdic---%@",dic);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed([NetworkTool dictionaryWithJsonString:responseStr]);
                    [[ActivityView shareAcctivity]hiddeActivity];
                });

            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                NSLog(@"error == %@", error);
                [[ActivityView shareAcctivity]hiddeActivity];
                [MyToast showWithText:@"请求失败，请稍后再试" duration:1.2];
                failure(error);
                
                
            }];
        }
            break;
            
        default:
            break;
    }
}


+(void)requestNOActivityAFURL:(NSString *)URLString
                   httpMethod:(NSInteger)method
                   parameters:(id)parameters
                      succeed:(void (^)(id))succeed
                      failure:(void (^)(NSError *))failure
{
    // 0.设置API地址
    URLString=[NetworkTool newUrlStr:URLString];
    // 1.创建请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 2.申明返回的结果是二进制类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.如果报接受类型不一致请替换一致text/html  或者 text/plain
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    // 4.请求超时，时间设置
    manager.requestSerializer.timeoutInterval =130;
    
    if (parameters==nil) {
        parameters = @{@"appid":APPID};
    }
    else
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:parameters];
        
        
        parameters=dic;
    }

    
    // 5.选择请求方式 GET 或 POST
    switch (method) {
        case METHOD_GET:
        {
            [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSString *responseStr =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed([NetworkTool dictionaryWithJsonString:responseStr]);
                    [[ActivityView shareAcctivity]hiddeActivity];
                });
                
                
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [[ActivityView shareAcctivity]hiddeActivity];
                failure(error);
                
                
                
            }];
        }
            break;
            
        case METHOD_POST:
        {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                
                 NSString *responseStr =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSDictionary *dic=[NetworkTool dictionaryWithJsonString:responseStr];

                NSLog(@"tongyongdic---%@",dic);
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed([NetworkTool dictionaryWithJsonString:responseStr]);
                    [[ActivityView shareAcctivity]hiddeActivity];
                });

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [MyToast showWithText:@"请求失败，请稍后再试" duration:1.2];
                failure(error);
            }];
        }
            break;
            
        default:
            break;
    }

}


+(void)requestNoActivityAFURL:(NSString *)URLString  parameters:(id)parameters succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure
{
    URLString=[NetworkTool newUrlStr:URLString];
    // 1.创建请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 2.申明返回的结果是二进制类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.如果报接受类型不一致请替换一致text/html  或者 text/plain
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    // 4.请求超时，时间设置
    manager.requestSerializer.timeoutInterval =30;
    
    if (parameters==nil) {
        
        
    }
    else
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:parameters];
      
        parameters=dic;
    }

    
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *responseStr =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic=[NetworkTool dictionaryWithJsonString:responseStr];
            if ([dic[@"resultCode"] isEqualToString:@"00000000"]) {
                succeed(dic);
            }
            else
            {
                if ([dic[@"resultCode"] isEqualToString:@"90000000"]) {
                   
                    NSError *error=[[NSError alloc] initWithDomain:dic[@"resultMessage"] code:[dic[@"resultCode"] integerValue] userInfo:nil];
                    failure(error);
                }
//                else if([dic[@"resultCode"] isEqualToString:@"99999999"])
//                {
//                    succeed(dic);
//                }
                else
                {
                    NSError *error=[[NSError alloc] initWithDomain:dic[@"resultMessage"] code:[dic[@"resultCode"] integerValue] userInfo:nil];
                    failure(error);
                }
               
            }
        });
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
        
    }];

    
}

#pragma mark - Session 下载下载文件
+ (void)sessionDownloadWithUrl:(NSString *)urlStr success:(void (^)(NSURL *fileURL))success fail:(void (^)())fail
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // 指定下载文件保存的路径
        //        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
        // 将下载文件保存在缓存路径中
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
        
        
        // URLWithString返回的是网络的URL,如果使用本地URL,需要注意
        //        NSURL *fileURL1 = [NSURL URLWithString:path];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(fileURL);
            });
        }
        
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
    
    [task resume];
}

+ (void)postUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    // 本地上传给服务器时,没有确定的URL,不好用MD5的方式处理
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //@"http://localhost/demo/upload.php"
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
    
        [formData appendPartWithFileURL:fileURL name:@"file" fileName:fileName mimeType:fileTye error:NULL];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail(error);
        }
    }];
}

+(void)upLoadWithUrl:(NSString *)urlStr data:(NSData *)data dataName:(NSString *)name fileType:(NSString *)fileType success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    [[ActivityView shareAcctivity]showActivity];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
   [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
       if (fileType!=nil&&fileType.length>0) {
           [formData appendPartWithFileData:data name:@"file" fileName:name mimeType:fileType];
       }
       else
       {
           [formData appendPartWithFormData:data name:@"file"];
       }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ActivityView shareAcctivity]hiddeActivity];
            NSDictionary *dic=responseObject;
            if ([dic[@"resultCode"] isEqualToString:@"00000000"]) {
                success(dic);
            }
            else
            {
                if ([dic[@"resultCode"] isEqualToString:@"90000000"]) {
                    NSError *error=[[NSError alloc] initWithDomain:dic[@"resultMessage"] code:[dic[@"resultCode"] integerValue] userInfo:nil];
                    fail(error);
                }
                else
                {
                    NSError *error=[[NSError alloc] initWithDomain:dic[@"resultMessage"] code:[dic[@"resultCode"] integerValue] userInfo:nil];
                    fail(error);
                }
                
            }
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[ActivityView shareAcctivity]hiddeActivity];
        [MyToast showWithText:@"请求失败，请稍后再试" duration:1.5];
        if (fail) {
            fail(error);
        }
    }];
}



+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        return nil;
    }
    return dic;
}

+(NSString *)newUrlStr:(NSString *)url
{
//    if (url!=nil) {
//        if([url rangeOfString:@"/loan/"].length>0)
//            return [url stringByReplacingOccurrencesOfString:@"/loan/" withString:@"/loandev/"];
//    }
//    else
//    {
//        return url;
//    }
    return url;
}

@end
