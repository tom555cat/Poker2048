//
//  MyUIButton.m
//  Tlm2048_1
//
//  Created by tom555cat on 16/1/4.
//  Copyright © 2016年 tom555cat. All rights reserved.
//

#import "MyUIButton.h"

@implementation MyUIButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

#define CORNER_FONT_STANDARD_HEIGHT 100.0
#define CORNER_RADIUS 6.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

- (void)drawRect:(CGRect)rect {
    UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    
    [roundRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    // 画黑色轮廓
    [[UIColor blackColor] setStroke];
    [roundRect stroke];
}


@end
