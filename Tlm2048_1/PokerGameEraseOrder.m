//
//  F3HEraseOrder.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerGameEraseOrder.h"

@implementation PokerGameEraseOrder

+ (instancetype)pokerMoveWithSource:(NSInteger)source
                        destination:(NSInteger)destination
                              poker:(F3HPokerModel *)poker
{
    PokerGameEraseOrder *order = [[self class] new];
    order.source1 = source;
    order.destination = destination;
    order.isMoving = YES;
    order.erasePoker1 = poker;
    return order;
}

+ (instancetype)erasePokersWithSources:(NSMutableArray *)sources
                                pokers:(NSMutableArray *)pokers
{
    PokerGameEraseOrder *order = [[self class] new];
    order.sources = sources;
    order.pokers = pokers;
    order.isMoving = NO;
    return order;
}

/*

+ (instancetype)eraseTwoPokerWithFirstSource:(NSInteger)source1
                                secondSource:(NSInteger)source2
{
    F3HEraseOrder *order = [[self class] new];
    order.source1 = source1;
    order.source2 = source2;
    order.isMoving = NO;
    return order;
}

+ (instancetype)eraseThreePokerWithFirstSource:(NSInteger)source1
                                  secondSource:(NSInteger)source2
                                   thirdSource:(NSInteger)source3
{
    F3HEraseOrder *order = [[self class] new];
    order.source1 = source1;
    order.source2 = source2;
    order.source3 = source3;
    order.isMoving = NO;
    return order;
}

+ (instancetype)eraseFourPokerWithFirstSource:(NSInteger)source1
                                 secondSource:(NSInteger)source2
                                  thirdSource:(NSInteger)source3
                                 fourthSource:(NSInteger)source4
{
    F3HEraseOrder *order = [[self class] new];
    order.source1 = source1;
    order.source2 = source2;
    order.source3 = source3;
    order.source4 = source4;
    order.isMoving = NO;
    return order;
}
 
 */

@end
