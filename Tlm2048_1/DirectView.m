//
//  DirectView.m
//  Poker2048
//
//  Created by tom555cat on 16/3/22.
//  Copyright © 2016年 tom555cat. All rights reserved.
//

#import "DirectView.h"

#define W CGRectGetWidth([UIScreen mainScreen].bounds)
#define H CGRectGetHeight([UIScreen mainScreen].bounds)

@interface DirectView ()

@property (nonatomic, strong) UIView *bigView;

@end

@implementation DirectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        CGSize winSize = [[UIScreen mainScreen] bounds].size;
        CGFloat imageWidth = 0.0f;
        CGFloat imageHeight = 0.0f;
        CGFloat currentTop = 0.0f;
        
        if (winSize.height >= winSize.width * 2.0f) {
            imageWidth = winSize.width;
            imageHeight = imageWidth;
        } else {
            imageWidth = winSize.height * 0.8f/ 2.0f;
            imageHeight = imageWidth;
        }
        
        self.bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight*2)];
        _bigView.layer.cornerRadius = 10;
        _bigView.layer.masksToBounds = YES;
        _bigView.backgroundColor = [UIColor whiteColor];
        _bigView.center = CGPointMake(W / 2, H / 2);
        [self addSubview:_bigView];
        
        // 添加指引图片
        CGFloat upperImageWidth = imageWidth;
        CGFloat upperImageHeight = imageHeight;
        UIImageView *upperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, upperImageWidth, upperImageHeight)];
        upperImageView.image = [UIImage imageNamed:@"swipe.png"];
        [_bigView addSubview:upperImageView];
        currentTop += upperImageHeight;
        
        CGFloat downImageWidth = imageWidth * 850.0f / 1024.0f;
        CGFloat downImageHeight = imageHeight * 850.0f / 1024.0f;
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth/2.0f - downImageWidth/2.0f, imageHeight*0.9f, downImageWidth, downImageHeight)];
        downImageView.image = [UIImage imageNamed:@"direct.png"];
        [_bigView addSubview:downImageView];
        currentTop += downImageHeight - 0.07f * upperImageHeight;
        
        // 响应触摸
        //UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quitDirectView:)];
        //[self addGestureRecognizer:tapGR];
        
        // 开始按钮
        CGFloat startGameBtnHeight = imageHeight * 150 / 1024.0f;
        CGFloat startGameBtnWidth = startGameBtnHeight * 106.0f / 34.0f;
        UIButton *startGameBtn = [[UIButton alloc] initWithFrame:CGRectMake(imageWidth/2.0f - startGameBtnWidth/2.0f, currentTop, startGameBtnWidth, startGameBtnHeight)];
        [startGameBtn setBackgroundImage:[UIImage imageNamed:@"short-button"] forState:UIControlStateNormal];
        [startGameBtn addTarget:self action:@selector(quitDirectView:) forControlEvents:UIControlEventTouchUpInside];
        [_bigView addSubview:startGameBtn];
    }
    
    return self;
}

- (void)quitDirectView:(id)sender
{
    [self dissmiss];
}

- (void)dissmiss {
    [UIView animateWithDuration:.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setup
{
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    CGFloat imageWidth = 0.0f;
    CGFloat imageHeight = 0.0f;
    
    if (winSize.height >= winSize.width * 2.0f) {
        imageWidth = winSize.width;
        imageHeight = imageWidth;
    } else {
        imageWidth = winSize.height / 2.0f;
        imageHeight = imageWidth;
    }
    
    CGFloat upperImageWidth = imageWidth;
    CGFloat upperImageHeight = imageHeight;
    UIImageView *upperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, winSize.height/2.0f-upperImageHeight, upperImageWidth, upperImageHeight)];
    upperImageView.image = [UIImage imageNamed:@"swipe.png"];
    [self addSubview:upperImageView];
    
    CGFloat downImageWidth = imageWidth;
    CGFloat downImageHeight = imageHeight;
    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, winSize.height/2.0f, downImageWidth, downImageHeight)];
    downImageView.image = [UIImage imageNamed:@"direct.png"];
    [self addSubview:downImageView];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [window addSubview:self];
}

@end
