//
//  F3HErasePoker.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class F3HPokerModel;

typedef NS_ENUM(NSInteger, PokerEraseMode) {
    PokerEraseModeEmpty,
    PokerEraseModeNoAction,
    PokerEraseModeMove,
    PokerEraseModeErase,
    PokerEraseModeTwoErase,
    PokerEraseModeThreeErase,
    PokerEraseModeFourErase
};

@interface PokerGameErasePoker : NSObject

@property (nonatomic) PokerEraseMode mode;

// '0'位置是当前poker原来的位置，后面是要一起消除的其他poker的位置
@property (nonatomic, strong) NSMutableArray *originalIndexArray;
// ‘0’位置是当前poker，后面是要和poker一起消除的poker
@property (nonatomic, strong) NSMutableArray *pokerArray;

@property (nonatomic) NSInteger originalIndexA;
@property (nonatomic) NSInteger originalIndexB;
@property (nonatomic) NSInteger originalIndexC;
@property (nonatomic) NSInteger originalIndexD;

+ (instancetype)erasePoker;

// 深拷贝方法
+ (id)copyWithErasePoker:(PokerGameErasePoker *)erasePoker;

@end
