//
//  CardBackScrollView.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/13.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ScrollDirection {
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

@protocol CardBackScrollViewDelegate <NSObject>
-(void)updateView:(UIView *)view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction;
@end

@protocol CardBackScrollViewDataSource <NSObject>
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view;
- (NSInteger)numberOfViews;
- (NSInteger)numberOfVisibleViews;
@end


@interface CardBackScrollView : UIView

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, weak) id<CardBackScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<CardBackScrollViewDelegate> delegate;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL pagingEnabled;
@property (nonatomic) NSInteger maxScrollDistance;

- (void)reloadData;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (UIView *)viewAtIndex:(NSInteger)index;
- (NSArray *)allViews;

@end
