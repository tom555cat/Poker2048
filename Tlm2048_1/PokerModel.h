//
//  F3HPokerModel.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreDefine.h"

/*
typedef struct
{
    F3HPokerColor pokerColor;
    F3HPokerNumber pokerNumber;
}F3HPokerValue;
 */

@interface PokerModel : NSObject

@property (nonatomic) BOOL isErased;
@property (nonatomic) BOOL empty;
@property (nonatomic) PokerColor pokerColor;
@property (nonatomic) PokerNumber pokerNumber;
+ (instancetype)emptyPoker;

// 深拷贝
+ (id)copyWithPoker:(PokerModel *)poker;

@end
