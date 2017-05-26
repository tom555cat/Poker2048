//
//  HelpPokerView.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/3.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "HelpPokerView.h"

@interface HelpPokerView()
@end

@implementation HelpPokerView

#define CORNER_FONT_STANDARD_HEIGHT 100.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

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

// 当rect为54高度时，字体设置成20正好合适，设置调节系数
static const CGFloat coefficent = 25.0f/54.5f;

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    
    [roundRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    // 画黑色轮廓
    [[UIColor blackColor] setStroke];
    [roundRect stroke];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    int currentFontSize = rect.size.height * coefficent;
    NSString *str = [NSString stringWithFormat:@"%@%@", [self rankAsString], self.suit];
    
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    [self setAttributedTitle:contentAttributedString forState:UIControlStateNormal];
}

- (NSString *)rankAsString
{
    return @[@"",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"][self.rank];
}

- (void)setRank:(NSInteger)rank
{
    _rank = rank;
    [self setNeedsDisplay];
}

- (void)setSuit:(NSString *)suit
{
    _suit = suit;
    [self setNeedsDisplay];
}

@end
