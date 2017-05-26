//
//  F3HErasePoker.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerGameErasePoker.h"
#import "PokerModel.h"


@implementation PokerGameErasePoker

+ (instancetype)erasePoker
{
    PokerGameErasePoker *erasePoker = [[PokerGameErasePoker class] new];
    erasePoker.originalIndexArray = [[NSMutableArray alloc] init];
    erasePoker.pokerArray = [[NSMutableArray alloc] init];
    return erasePoker;
}

+ (instancetype)copyWithErasePoker:(PokerGameErasePoker *)poker
{
    PokerGameErasePoker *copyErasePoker = [PokerGameErasePoker erasePoker];
    for (NSInteger i = 0; i < [poker.originalIndexArray count]; i++) {
        NSNumber *originalIndex1 = [NSNumber numberWithInteger:[(NSNumber *)poker.originalIndexArray[i] integerValue]];
        [copyErasePoker.originalIndexArray addObject:originalIndex1];
    }
    for (NSInteger i = 0; i < [poker.pokerArray count]; i++) {
        PokerModel *copyPoker = [PokerModel copyWithPoker:poker.pokerArray[i]];
        [copyErasePoker.pokerArray addObject:copyPoker];
    }
    copyErasePoker.mode = poker.mode;
    return copyErasePoker;
}


- (NSString *)description {
    NSString *modeStr;
    switch (self.mode) {
        case PokerEraseModeEmpty:
            modeStr = @"Empty";
            break;
        case PokerEraseModeNoAction:
            modeStr = @"NoAction";
            break;
        case PokerEraseModeMove:
            modeStr = @"Move";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"Erase Poker (mode: %@, source1: %ld, source2: %ld, source3:%ld, source4:%ld)",
            modeStr,
            (long)self.originalIndexA,
            (long)self.originalIndexB,
            (long)self.originalIndexC,
            (long)self.originalIndexD];
}


@end
