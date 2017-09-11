//
//  NSArray+QBSafeAccess.m
//  FanbaMobileApp
//
//  Created by qianbaoeo on 2017/2/24.
//
//

#import "NSArray+QBSafeAccess.h"

@implementation NSArray (QBSafeAccess)
- (id)safe_objectAtIndex:(NSUInteger)cIndex
{
    if (cIndex < self.count) {
        return self[cIndex];
    }
    return nil;
}

@end
@implementation NSMutableArray (SUISafeAccess)
- (void)safe_addObject:(id)a;
{
    if (a != nil && a != NULL) {
        [self addObject:a];
    }
}
@end
