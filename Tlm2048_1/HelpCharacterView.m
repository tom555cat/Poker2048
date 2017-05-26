//
//  HelpCharacterView.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/4.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "HelpCharacterView.h"

@implementation HelpCharacterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 当rect为54高度时，字体设置成20正好合适，设置调节系数
static const CGFloat coefficent = 20.0f/54.5f;
- (void)drawRect:(CGRect)rect {
    
    CGSize maxSize = CGSizeMake(rect.size.width, rect.size.height);
    int currentFontSize = rect.size.height * coefficent;
    NSString *str = self.content;
    
    CGSize requiredSize = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize]} context:nil].size;
    
    // 绘制文本
    NSLog(@"the font size is: %d", currentFontSize);
    [str drawAtPoint:CGPointMake(0, rect.size.height/2 - requiredSize.height/2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize], NSForegroundColorAttributeName:(self.textColor == nil ? [UIColor blackColor] : self.textColor)}];

}

- (void)setContent:(NSString *)content
{
    _content = content;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay];
}

@end
