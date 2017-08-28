//
//  NSDictionary+QBSafeAccess.h
//  FanbaMobileApp
//
//  Created by qianbaoeo on 2017/2/24.
//
//

#import <Foundation/Foundation.h>
#define kNilOrNull(__ref) (((__ref) == nil) || ([(__ref) isEqual:[NSNull null]]))
@interface NSDictionary (QBSafeAccess)
- (nullable id)safe_objectForKey:(NSString *)cKey;

@end
@interface NSMutableDictionary(QBSafeAccess)
- (void)safe_setObj:(id)a forKey:(NSString *)cKey;
@end
