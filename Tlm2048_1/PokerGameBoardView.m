//
//  F3HPokerGameBoardView.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/26.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerGameBoardView.h"

#import <QuartzCore/QuartzCore.h>
#import "F3HTileAppearanceProvider.h"
#import "PokerView.h"
#import "CardBackView.h"

#define PER_SQUARE_SLIDE_DURATION 0.08

#if DEBUG
#define F3HLOG(...) NSLog(__VA_ARGS__)
#else
#define F3HLOG(...)
#endif

// Animation parameter
#define TILE_POP_START_SCALE    0.8
#define TILE_POP_MAX_SCALE      1.5
#define TILE_TRASH_SCALE        0.5
#define TILE_POP_DELAY          0.05
#define TILE_EXPAND_TIME        0.2
#define TILE_RETRACT_TIME       0.2
#define TILE_TURN_OVER_TIME     0.8
#define TILE_FLY_AWAY           0.8
#define TILE_FLIP_OVER          0.5

#define TILE_MERGE_START_SCALE  1.0
#define TILE_MERGE_EXPAND_TIME  0.08
#define TILE_MERGE_RETRACT_TIME 0.08

@interface PokerGameBoardView ()

@property (nonatomic, strong) NSMutableDictionary *backgroundTiles;
@property (nonatomic) NSUInteger dimension;
//@property (nonatomic) CGFloat pokerSideLength;

@property (nonatomic) CGFloat pokerSideWidth;
@property (nonatomic) CGFloat pokerSideHeight;

@property (nonatomic) CGFloat padding;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *tileBackgroundColor;

@property (nonatomic, strong) F3HTileAppearanceProvider *provider;

@end

@implementation PokerGameBoardView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                            cellHeight:(CGFloat)height
                           cellPadding:(CGFloat)padding
                          cornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor
{
    // CGFloat sideLength = padding + dimension * (width + padding);
    CGFloat sideWidth = padding + dimension * (width + padding);
    CGFloat sideHeight = padding + dimension * (height + padding);
    PokerGameBoardView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, sideWidth, sideHeight)];
    view.dimension = dimension;
    view.padding = padding;
    view.pokerSideWidth = width;
    view.pokerSideHeight = height;
    view.layer.cornerRadius = cornerRadius;
    view.cornerRadius = cornerRadius;
    view.tileBackgroundColor = foregroundColor;
    [view setupBackgroundWithBackgroundColor:backgroundColor foregroundColor:foregroundColor];
    return view;
}

- (void)setCardBackImageStr:(NSString *)cardBackImageStr
{
    _cardBackImageStr = cardBackImageStr;
}

- (void)reset
{
    NSLog(@"before reset, the poker number in boardPokers is: %lu", (unsigned long)[self.boardPokers count]);
    for (NSString *key in self.boardPokers) {
        PokerView *poker = self.boardPokers[key];
        [poker removeFromSuperview];
    }
    [self.boardPokers removeAllObjects];
    
    for (NSInteger i = 0; i < self.dimension; i++) {
        for (NSInteger j = 0; j < self.dimension; j++) {
            UIView *bkgndTile = self.backgroundTiles[[NSIndexPath indexPathForRow:i inSection:j]];
            for (UIView *view in [bkgndTile subviews]) {
                [view removeFromSuperview];
            }
        }
    }
    
    //清除所有subview
    NSArray *subview = [self subviews];
    NSLog(@"******** The Left Subview number is: %lu", (unsigned long)[subview count]);
}

- (void)setupBackgroundWithBackgroundColor:(UIColor *)background
                           foregroundColor:(UIColor *)foreground
{
    self.backgroundColor = background;
    CGFloat xCursor = self.padding;
    CGFloat yCursor;
    CGFloat cornerRadius = self.cornerRadius - 2;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    for (NSInteger i=0; i<self.dimension; i++) {
        yCursor = self.padding;
        for (NSInteger j=0; j<self.dimension; j++) {
            //UIView *bkgndTile = [[UIView alloc] initWithFrame:CGRectMake(xCursor, yCursor, self.pokerSideLength, self.pokerSideLength)];
            UIView *bkgndTile = [[UIView alloc] initWithFrame:CGRectMake(xCursor, yCursor, self.pokerSideWidth, self.pokerSideHeight)];
            bkgndTile.layer.cornerRadius = cornerRadius;
            bkgndTile.backgroundColor = foreground;
            [self addSubview:bkgndTile];
            [self.backgroundTiles setObject:bkgndTile forKey:[NSIndexPath indexPathForRow:j inSection:i]];
            yCursor += self.padding + self.pokerSideHeight;
        }
        xCursor += self.padding + self.pokerSideWidth;
    }
}

// Insert a poker, with the poping animation
- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                    completion:(void(^)())completion
{
    F3HLOG(@"GameboardView--Inserting poker at row %ld, column %ld", (long)path.row, (long)path.section);
    if (!path
        || path.row >= self.dimension
        || path.section >= self.dimension
        || self.boardPokers[path]) {
        // Index path out of bounds, or there already is a tile
        return;
    }

    CGFloat x = self.padding + path.section*(self.pokerSideWidth + self.padding);
    CGFloat y = self.padding + path.row*(self.pokerSideHeight + self.padding);
    CGPoint position = CGPointMake(x, y);
    CGFloat cornerRadius = self.cornerRadius;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    
    // construct poker
    PokerView *poker = [PokerView pokerForPosition:position
                                          sideWidth:self.pokerSideWidth
                                              sideHeight:self.pokerSideHeight
                                               pokerColor:(int)color
                                            pokerNumber:(int)number
                                        cornerRadius:cornerRadius];
    
    //poker.delegate = self.provider;
    self.boardPokers[path] = poker;
    
    // 卡背
    CardBackView *cardBack = [CardBackView cardBackPosition:position sideWidth:self.pokerSideWidth sideHeight:self.pokerSideHeight cornerRadius:cornerRadius];
    cardBack.imageNameStr = self.cardBackImageStr;
    cardBack.frame = poker.frame;
    
    // 取poker对应的tile
    NSInteger row = path.row;
    NSInteger section = path.section;
    NSLog(@"%lu", (unsigned long)[self.backgroundTiles count]);
    UIView *bkgndTile = self.backgroundTiles[[NSIndexPath indexPathForRow:row inSection:section]];
    
    // 保存旧的frame和新的frame
    CGRect oldFrame = poker.frame;
    CGRect newFrame = CGRectMake(bkgndTile.frame.size.width/2.0f-self.pokerSideWidth/2.0f, bkgndTile.frame.size.height/2.0f-self.pokerSideHeight/2.0f, self.pokerSideWidth, self.pokerSideHeight);
    
    //poker.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_START_SCALE, TILE_POP_START_SCALE);
    //[self addSubview:poker];
    
    poker.frame = newFrame;
    cardBack.frame = newFrame;
    [bkgndTile addSubview:cardBack];
    
    [UIView animateWithDuration:0 animations:^{
        bkgndTile.backgroundColor = [UIColor grayColor];
    } completion:^(BOOL finished) {
        [UIView transitionFromView:cardBack toView:poker duration:TILE_FLIP_OVER options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            bkgndTile.backgroundColor = self.tileBackgroundColor;
            [poker removeFromSuperview];
            [cardBack removeFromSuperview];
            poker.frame = oldFrame;
            [self addSubview:poker];
            
            if (completion != nil) {
                completion();
            }
        }];
    }];
}

- (void)insertPokerAtIndexPath:(NSIndexPath *)path
                         color:(NSInteger)color
                        number:(NSInteger)number
                         delay:(CGFloat)delay
                    completion:(void(^)())completion
{
    //F3HLOG(@"GameboardView--Inserting poker at row %ld, column %ld", (long)path.row, (long)path.section);
    if (!path
        || path.row >= self.dimension
        || path.section >= self.dimension
        || self.boardPokers[path]) {
        // Index path out of bounds, or there already is a tile
        return;
    }
    
    CGFloat x = self.padding + path.section*(self.pokerSideWidth + self.padding);
    CGFloat y = self.padding + path.row*(self.pokerSideHeight + self.padding);
    CGPoint position = CGPointMake(x, y);
    CGFloat cornerRadius = self.cornerRadius;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    
    // construct poker
    PokerView *poker = [PokerView pokerForPosition:position
                                               sideWidth:self.pokerSideWidth
                                              sideHeight:self.pokerSideHeight
                                              pokerColor:(int)color
                                             pokerNumber:(int)number
                                            cornerRadius:cornerRadius];
    
    //poker.delegate = self.provider;
    self.boardPokers[path] = poker;
    
    // 卡背
    CardBackView *cardBack = [CardBackView cardBackPosition:position sideWidth:self.pokerSideWidth sideHeight:self.pokerSideHeight cornerRadius:cornerRadius];
    cardBack.imageNameStr = self.cardBackImageStr;
    cardBack.frame = poker.frame;
    
    // 取poker对应的tile
    NSInteger row = path.row;
    NSInteger section = path.section;
    NSLog(@"%lu", (unsigned long)[self.backgroundTiles count]);
    UIView *bkgndTile = self.backgroundTiles[[NSIndexPath indexPathForRow:row inSection:section]];
    
    // 保存旧的frame和新的frame
    CGRect oldFrame = poker.frame;
    CGRect newFrame = CGRectMake(bkgndTile.frame.size.width/2.0f-self.pokerSideWidth/2.0f, bkgndTile.frame.size.height/2.0f-self.pokerSideHeight/2.0f, self.pokerSideWidth, self.pokerSideHeight);
    
    //poker.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_START_SCALE, TILE_POP_START_SCALE);
    //[self addSubview:poker];
    
    poker.frame = newFrame;
    cardBack.frame = newFrame;
    [bkgndTile addSubview:cardBack];
    
    [UIView animateWithDuration:0 delay:delay options:0 animations:^{
        bkgndTile.backgroundColor = [UIColor grayColor];
    } completion:^(BOOL finished) {
        [UIView transitionFromView:cardBack toView:poker duration:TILE_FLIP_OVER options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            bkgndTile.backgroundColor = self.tileBackgroundColor;
            [poker removeFromSuperview];
            [cardBack removeFromSuperview];
            poker.frame = oldFrame;
            [self addSubview:poker];
            
            if (completion != nil) {
                completion();
            }
        }];
    }];

}


// Move a poker from one tile onto another tile,
- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath
                   toIndexPath:(NSIndexPath *)toPath
{
    //F3HLOG(@"Moving poker at row %ld, column %ld to destination row %ld, column %ld", (long)fromPath.row, (long)fromPath.section, (long)toPath.row, (long)toPath.section);
    if (!fromPath || !toPath || !self.boardPokers[fromPath]
        || toPath.row > self.dimension
        || toPath.section >= self.dimension) {
        NSAssert(NO, @"Invalid one-tile move and merge");
        return;
    }
    PokerView *startPoker = self.boardPokers[fromPath];
    //F3HPokerView *endPoker = self.boardPokers[toPath];      3.10号注释
    //BOOL shouldPop = endPoker != nil;                       3.10号注释
    
    CGFloat x = self.padding + toPath.section*(self.pokerSideWidth + self.padding);
    CGFloat y = self.padding + toPath.row*(self.pokerSideHeight + self.padding);
    CGRect finalFrame = startPoker.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
    
    // Update board state
    [self.boardPokers removeObjectForKey:fromPath];
    self.boardPokers[toPath] = startPoker;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION)
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         startPoker.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         // empty
                         }];
}

- (void)movePokerFromIndexPath:(NSIndexPath *)fromPath
                   toIndexPath:(NSIndexPath *)toPath
                         delay:(CGFloat)delay
{
    //F3HLOG(@"Moving poker at row %ld, column %ld to destination row %ld, column %ld", (long)fromPath.row, (long)fromPath.section, (long)toPath.row, (long)toPath.section);
    if (!fromPath || !toPath || !self.boardPokers[fromPath]
        || toPath.row > self.dimension
        || toPath.section >= self.dimension) {
        NSAssert(NO, @"Invalid one-tile move and merge");
        return;
    }
    PokerView *startPoker = self.boardPokers[fromPath];
    //F3HPokerView *endPoker = self.boardPokers[toPath];    //3.10号注释
    //BOOL shouldPop = endPoker != nil;      //3.10号注释
    
    CGFloat x = self.padding + toPath.section*(self.pokerSideWidth + self.padding);
    CGFloat y = self.padding + toPath.row*(self.pokerSideHeight + self.padding);
    CGRect finalFrame = startPoker.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
    
    // Update board state
    [self.boardPokers removeObjectForKey:fromPath];
    self.boardPokers[toPath] = startPoker;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION)
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         startPoker.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         // empty
                     }];
}


- (void)erasePokers:(NSMutableArray *)pathArray
{
    F3HLOG(@"Erase pokers at:");
    /*
    for (NSInteger i = 0; i < [pathArray count]; i++) {
        NSIndexPath *path = pathArray[i];
        F3HLOG(@"row %ld, column %ld", (long)(path.row), (long)(path.section));
    }
     */
    if (!pathArray || [pathArray count] <= 0) {
        NSAssert(NO, @"Invalid poker erase");
        return;
    }
    
    NSMutableArray *erasePokers = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [pathArray count]; i++) {
        [erasePokers addObject:self.boardPokers[pathArray[i]]];
        [self.boardPokers removeObjectForKey:pathArray[i]];
    }
    
    for (NSInteger i = 0; i < [erasePokers count]; i++) {
        PokerView *poker = erasePokers[i];
        CGPoint newOrigin = [self.parentViewController.view convertPoint:poker.frame.origin fromView:self];
        [poker removeFromSuperview];
        poker.frame = CGRectMake(newOrigin.x, newOrigin.y, self.pokerSideWidth, self.pokerSideHeight);
        [self.parentViewController.view addSubview:poker];
        [self.parentViewController.view bringSubviewToFront:poker];
    }
    
    for (NSInteger i = 0; i < [pathArray count]; i++) {
        UIView *bkgndTile = self.backgroundTiles[pathArray[i]];
        
        // 被消除的poker
        PokerView *poker = erasePokers[i];
        
        // 对应的卡背
        CardBackView *cardBack = [CardBackView cardBackPosition:CGPointMake(0, 0) sideWidth:self.pokerSideWidth sideHeight:self.pokerSideHeight cornerRadius:2.0];
        cardBack.imageNameStr = self.cardBackImageStr;
        cardBack.frame = poker.frame;
        
        // 保存新的frame和旧的frame信息
        CGRect newFrame = CGRectMake(bkgndTile.frame.size.width/2.0f-self.pokerSideWidth/2.0f, bkgndTile.frame.size.height/2.0f-self.pokerSideHeight/2.0f, self.pokerSideWidth, self.pokerSideHeight);
        CGRect oldFrame = poker.frame;
        
        [poker removeFromSuperview];
        poker.frame = newFrame;
        cardBack.frame = newFrame;
        
        //[bkgndTile addSubview:cardBack];
        [bkgndTile addSubview:poker];
        
        // 卡牌翻转动画
        [UIView animateWithDuration:0 animations:^{
            bkgndTile.backgroundColor = [UIColor grayColor];
        } completion:^(BOOL finished) {
            [UIView transitionFromView:poker toView:cardBack duration:TILE_FLIP_OVER options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
                if (finished) {
                    [cardBack removeFromSuperview];
                    [poker removeFromSuperview];
                    poker.frame = oldFrame;
                    bkgndTile.backgroundColor = self.tileBackgroundColor;
                    [self.parentViewController.view addSubview:poker];
                    [self.parentViewController.view bringSubviewToFront:poker];
                    
                    // fly away
                    [UIView animateWithDuration:TILE_FLY_AWAY animations:^{
                        poker.frame = self.trashFrame;
                    } completion:^(BOOL finished) {
                        [poker removeFromSuperview];
                        //[self.boardPokers removeObjectForKey:pathArray[i]];
                    }];
                }
            }];
        }];
    }
    [erasePokers removeAllObjects];
}

- (F3HTileAppearanceProvider *)provider
{
    if (!_provider) {
        _provider = [F3HTileAppearanceProvider new];
    }
    return _provider;
}

- (NSMutableDictionary *)boardPokers
{
    if (!_boardPokers) {
        _boardPokers = [NSMutableDictionary dictionary];
    }
    return _boardPokers;
}

- (NSMutableDictionary *)backgroundTiles
{
    if (!_backgroundTiles) {
        _backgroundTiles = [[NSMutableDictionary alloc] init];
    }
    return _backgroundTiles;
}

- (UIColor *)tileBackgroundColor
{
    if (!_tileBackgroundColor) {
        _tileBackgroundColor = [[UIColor alloc] init];
    }
    return _tileBackgroundColor;
}

@end
