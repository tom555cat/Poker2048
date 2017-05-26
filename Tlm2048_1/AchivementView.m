//
//  AchivementView.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/27.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "AchivementView.h"
#import "CardBackViewDisplay.h"

@interface AchivementView ()
@property (nonatomic, strong) UILabel *achivementLabel;
@property (nonatomic, strong) CardBackViewDisplay *cardBackView;
@end

@implementation AchivementView


static const CGFloat coefficent=20.0f/40.0f;
- (void)setAchivementDiscription:(NSString *)achivementDiscription
{
    // 设置字体大小
    CGFloat fontSize = coefficent * self.achivementLabel.frame.size.height;
    
    // 设置段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:achivementDiscription];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                     NSFontAttributeName:[UIFont fontWithName:@"Verdana-Bold" size:fontSize],
                                     NSParagraphStyleAttributeName:paragraphStyle}
                             range:NSMakeRange(0, [achivementDiscription length])];
    self.achivementLabel.attributedText = attributeString;
}

- (void)setCardBackImageStr:(NSString *)cardBackImageStr
{
    self.cardBackView.imageNameStr = cardBackImageStr;
}

+ (instancetype)achivementWithPosition:(CGPoint)position
                             sideWidth:(CGFloat)sideWidth
                            sideHeight:(CGFloat)sideHeight
                          cardBackImageStr:(NSString *)cardBackImageStr
                 achivementDiscription:(NSString *)achivementDescription
{
    AchivementView *achivementView = [[AchivementView alloc] initWithFrame:CGRectMake(position.x, position.y, sideWidth, sideHeight)];
    achivementView.cardBackImageStr = cardBackImageStr;
    achivementView.achivementDiscription = achivementDescription;
    //achivementView.backgroundColor = [UIColor orangeColor];
    return achivementView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // 布局状况
        // 20% ----> UILabel
        // 5%  ---->  padding
        // 75% ---->  cardBackView
        CGFloat currentTop = 0.0;
        CGSize winSize = frame.size;
        
        // 成就描述标签
        UILabel *achivementLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        achivementLabel.frame = CGRectMake(0, currentTop, winSize.width, winSize.height*0.1f);
        self.achivementLabel = achivementLabel;
        [self addSubview:self.achivementLabel];
        currentTop += winSize.height*0.15;
        
        //  cardBackView
        CGFloat cardBackViewHeight = winSize.height*0.85f;
        CGFloat cardBackViewWidth = cardBackViewHeight*0.6f;
        CardBackViewDisplay *cardBackView = [CardBackViewDisplay cardBackPosition:CGPointMake(winSize.width/2.0f-cardBackViewWidth/2.0f, currentTop) sideWidth:cardBackViewWidth sideHeight:cardBackViewHeight cornerRadius:3.0];
        self.cardBackView = cardBackView;
        [self addSubview:self.cardBackView];
    }
    
    return self;
}

@end
