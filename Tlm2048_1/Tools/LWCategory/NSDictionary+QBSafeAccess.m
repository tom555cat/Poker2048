//
//  NSDictionary+QBSafeAccess.m
//  FanbaMobileApp
//
//  Created by qianbaoeo on 2017/2/24.
//
//

#import "NSDictionary+QBSafeAccess.h"

@implementation NSDictionary (QBSafeAccess)
- (id)safe_objectForKey:(NSString *)cKey
{
    id curValue = [self objectForKey:cKey];
    if (!kNilOrNull(curValue)) {
        return curValue;
    }
    return nil;
}

@end
@implementation NSMutableDictionary (QBSafeAccess)
- (void)safe_setObj:(id)a forKey:(NSString *)cKey
{
    if (a != nil && a != NULL) {
        [self setObject:a forKey:cKey];
        
    }
}

@end
