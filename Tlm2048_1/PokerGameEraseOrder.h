//
//  F3HEraseOrder.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/25.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <Foundation/Foundation.h>
@class F3HPokerModel;


@interface PokerGameEraseOrder : NSObject

@property (nonatomic) NSInteger source1;
@property (nonatomic) NSInteger source2;
@property (nonatomic) NSInteger source3;
@property (nonatomic) NSInteger source4;
@property (nonatomic) NSInteger destination;
@property (nonatomic) BOOL isMoving;
@property (nonatomic, strong) F3HPokerModel *erasePoker1;
@property (nonatomic, strong) F3HPokerModel *erasePoker2;
@property (nonatomic, strong) F3HPokerModel *erasePoker3;
@property (nonatomic, strong) F3HPokerModel *erasePoker4;

@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, strong) NSMutableArray *pokers;


+ (instancetype)pokerMoveWithSource:(NSInteger)source
                        destination:(NSInteger)destination
                              poker:(F3HPokerModel *)poker;

+ (instancetype)erasePokersWithSources:(NSMutableArray *)sources
                                pokers:(NSMutableArray *)pokers;


@end
