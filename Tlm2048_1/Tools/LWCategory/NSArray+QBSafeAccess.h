//
//  NSArray+QBSafeAccess.h
//  FanbaMobileApp
//
//  Created by qianbaoeo on 2017/2/24.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (QBSafeAccess)
- (id)safe_objectAtIndex:(NSUInteger)cIndex;
@end

@interface NSMutableArray (QBSafeAccess)
- (void)safe_addObject:(id)a;
@end
