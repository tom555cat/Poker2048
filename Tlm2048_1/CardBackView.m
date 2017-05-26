//
//  CardBackView.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/13.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "CardBackView.h"

@interface CardBackView()
@property (nonatomic, strong) UIImageView *cardBackImageView;

@end

@implementation CardBackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)cardBackPosition:(CGPoint)position sideWidth:(CGFloat)sideWidth sideHeight:(CGFloat)sideHeight cornerRadius:(CGFloat)cornerRadius
{
    CardBackView *cardBack = [[self alloc] initWithFrame:CGRectMake(position.x, position.y, sideWidth, sideHeight)];
    
    return cardBack;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // 将背景设置为透明
        self.backgroundColor = nil;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
        
        // 卡背外边框
        self.layer.cornerRadius = 3.0;
        
        // 卡牌中心内容
        CGFloat padding = frame.size.width * 0.1f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, frame.size.height-2*padding)];
        [self addSubview:imageView];
        self.cardBackImageView = imageView;
    }
    
    return self;
}

@synthesize imageNameStr = _imageNameStr;

- (NSString *)imageNameStr
{
    if (!_imageNameStr) {
        _imageNameStr = [[NSString alloc] init];
    }
    return _imageNameStr;
}

- (void)setImageNameStr:(NSString *)imageNameStr
{
    //self.cardBackImageView.image = [UIImage imageNamed:imageNameStr];
    
    // 获取纹理图片
    //UIImage *backgroundImage = [UIImage imageNamed:imageNameStr];
    
    if ([UIImage imageNamed:[NSString stringWithFormat:@"%@q",imageNameStr]] != nil) {
        UIImage *backgroundImage = nil;
        
        NSString *deviceType = [UIDevice currentDevice].model;
        if ([deviceType isEqualToString:@"iPhone"]) {
            backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@q",imageNameStr]];
        } else {
            backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@h",imageNameStr]];
        }
        
        self.cardBackImageView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
    
}

#pragma mark - drawing

#define CORNER_FONT_STANDARD_HEIGHT 100.0
#define CORNER_RADIUS 5.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

 - (void)drawRect:(CGRect)rect {
     // Drawing code
     // 设置扑克view圆角边缘
     UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
     [roundRect addClip];
 
     [[UIColor whiteColor] setFill];
     UIRectFill(self.bounds);
 
     // 设置扑克黑色轮廓
     [[UIColor blackColor] setStroke];
     [roundRect stroke];
}


@end
