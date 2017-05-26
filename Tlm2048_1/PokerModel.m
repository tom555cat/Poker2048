//
//  F3HPokerModel.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerModel.h"

@implementation PokerModel

+ (instancetype)emptyPoker
{
    PokerModel *poker = [[self class] new];
    poker.empty = YES;
    poker.isErased = NO;
    poker.pokerColor = 0;
    poker.pokerNumber = 0;
    return poker;
}

+ (id)copyWithPoker:(PokerModel *)poker
{
    PokerModel *copyPoker = [PokerModel emptyPoker];
    copyPoker.empty = poker.empty;
    copyPoker.pokerColor = poker.pokerColor;
    copyPoker.pokerNumber = poker.pokerNumber;
    return copyPoker;
}

- (NSString *)description
{
    if (self.empty) {
        return @"Poker (empty)";
    }
    return [NSString stringWithFormat:@"Poker (color: %lu) (number: %lu)", (unsigned long)self.pokerColor, (unsigned long)self.pokerNumber];
}



@end
