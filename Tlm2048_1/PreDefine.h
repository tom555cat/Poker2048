//
//  F3HPreDefine.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/27.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#ifndef PreDefine_h
#define PreDefine_h

typedef NS_ENUM(NSInteger, PokerColor) {
    PokerColorEmpty,
    PokerColorSpade,
    PokerColorHeart,
    PokerColorClub,
    PokerColorDiamond,
    PokerColorJoker      // 代表大小王的花色
};

typedef NS_ENUM(NSInteger, PokerNumber) {
    PokerNumberEmpty,
    PokerNumber1,
    PokerNumber2,
    PokerNumber3,
    PokerNumber4,
    PokerNumber5,
    PokerNumber6,
    PokerNumber7,
    PokerNumber8,
    PokerNumber9,
    PokerNumber10,
    PokerNumber11,
    PokerNumber12,
    PokerNumber13,
    PokerNumberJokerB,  // 小王
    PokerNumberJokerA   // 大王
};

typedef NS_ENUM(NSInteger, MoveDirection) {
    MoveDirectionUp,
    MoveDirectionDown,
    MoveDirectionLeft,
    MoveDirectionRight
};

/*
typedef enum
{
    F3HPokerColorEmpty = 0,
    F3HPokerColorSpade,
    F3HPokerColorHeart,
    F3HPokerColorClub,
    F3HPokerColorDiamond,
    F3HPokerColorJoker      // 代表大小王的花色
}F3HPokerColor;

typedef enum
{
    F3HPokerNumberEmpty = 0,
    F3HPokerNumber1,
    F3HPokerNumber2,
    F3HPokerNumber3,
    F3HPokerNumber4,
    F3HPokerNumber5,
    F3HPokerNumber6,
    F3HPokerNumber7,
    F3HPokerNumber8,
    F3HPokerNumber9,
    F3HPokerNumber10,
    F3HPokerNumber11,
    F3HPokerNumber12,
    F3HPokerNumber13,
    F3HPokerNumberJokerB,  // 小王
    F3HPokerNumberJokerA   // 大王
}F3HPokerNumber;

typedef enum
{
    F3HMoveDirectionUp = 0,
    F3HMoveDirectionDown,
    F3HMoveDirectionLeft,
    F3HMoveDirectionRight
}F3HMoveDirection;
*/

#endif /* PreDefine_h */
