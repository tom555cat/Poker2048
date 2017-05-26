//
//  HelpViewController.m
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/3.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpPokerView.h"
#import "HelpCharacterView.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBoard];
}

// 界面
// 绘制界面占整个界面的60%，从15%的高度开始绘制；
// 每张扑克牌占界面宽度的8%(可能还会调整),宽高比为3:5
// 绘图界面分成7等分，包括6个padding
// 每一行中，扑克牌部分占2/5；扑克牌之间的padding1，扑克牌与label之间的padding2
- (void)setupBoard
{
    CGFloat paddingHeight = 3.0;
    CGFloat paddingPoker = 1.0;
    CGFloat paddingLabel = 4.0;
    CGFloat pokerRatio = 5.0 / 12.0;
    CGSize winSize = [[UIScreen mainScreen] bounds].size;
    // 每行高度
    CGFloat cellHeight = (winSize.height * 0.6 - 6.0f * paddingHeight) / 7.0f;
    CGFloat cellWidth = cellHeight * 3.0 / 5.0;
    // 当前高度
    CGFloat currentTop = winSize.height * 0.15f;
    // label的宽度
    CGFloat pointLabelWidth = ((1 - pokerRatio) * winSize.width - 3 * paddingLabel) / 5.0f;
    CGFloat descriptionLabelWidth = pointLabelWidth * 4.0;
    // 得分段落样式
    NSMutableParagraphStyle *scoreParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    scoreParagraphStyle.alignment = NSTextAlignmentRight;
    // 说明
    NSMutableParagraphStyle *descriptionParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    descriptionParagraphStyle.alignment = NSTextAlignmentLeft;
    // 字体大小,0.37是一个字体和屏高的一个合适比例
    CGFloat currentFontSize = winSize.height * 13.0f /480.0f;
    
    // 第一行
    CGFloat x1 = winSize.width * pokerRatio - cellWidth;
    CGFloat y1 = currentTop;
    HelpPokerView *p1 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x1, y1, cellWidth, cellHeight)];
    p1.rank = 1;
    p1.suit = @"";
    [self.view addSubview:p1];
    
    CGFloat x2 = x1 - cellWidth - paddingPoker;
    CGFloat y2 = currentTop;
    HelpPokerView *p2 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x2, y2, cellWidth, cellHeight)];
    p2.rank = 1;
    p2.suit = @"";
    [self.view addSubview:p2];
    
    CGFloat x3 = x2 - cellWidth - paddingPoker;
    CGFloat y3 = currentTop;
    HelpPokerView *p3 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x3, y3, cellWidth, cellHeight)];
    p3.rank = 0;
    p3.suit = @"♦︎";
    //[self.view addSubview:p3];
    
    CGFloat x4 = x3 - cellWidth - paddingPoker;
    CGFloat y4 = currentTop;
    HelpPokerView *p4 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x4, y4, cellWidth, cellHeight)];
    p4.rank = 0;
    p4.suit = @"♦︎";
    //[self.view addSubview:p4];
    
    CGFloat x5 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y5 = currentTop;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(x5, y5, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString1 = [[NSMutableAttributedString alloc] initWithString:@"1⭐️"
                                      attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                                                                   NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                                                                   NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label1.attributedText = scoreAttributeString1;
    [self.view addSubview:label1];
    
    CGFloat x6 = x5 + pointLabelWidth + paddingLabel;
    CGFloat y6 = currentTop;
    HelpCharacterView *label2 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x6, y6, descriptionLabelWidth, cellHeight)];
    label2.content = @"Pair";
    label2.textColor = [UIColor blackColor];
    [self.view addSubview:label2];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    
    // 第二行
    CGFloat x21 = winSize.width * pokerRatio - cellWidth;
    CGFloat y21 = currentTop;
    HelpPokerView *p21 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x21, y21, cellWidth, cellHeight)];
    p21.rank = 2;
    p21.suit = @"";
    [self.view addSubview:p21];
    
    CGFloat x22 = x21 - cellWidth - paddingPoker;
    CGFloat y22 = currentTop;
    HelpPokerView *p22 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x22, y22, cellWidth, cellHeight)];
    p22.rank = 2;
    p22.suit = @"";
    [self.view addSubview:p22];
    
    CGFloat x23 = x22 - cellWidth - paddingPoker;
    CGFloat y23 = currentTop;
    HelpPokerView *p23 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x23, y23, cellWidth, cellHeight)];
    p23.rank = 2;
    p23.suit = @"";
    [self.view addSubview:p23];
    
    CGFloat x24 = x23 - cellWidth - paddingPoker;
    CGFloat y24 = currentTop;
    HelpPokerView *p24 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x24, y24, cellWidth, cellHeight)];
    p24.rank = 0;
    p24.suit = @"♦︎";
    //[self.view addSubview:p24];
    
    CGFloat x25 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y25 = currentTop;
    UILabel *label21 = [[UILabel alloc] initWithFrame:CGRectMake(x25, y25, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString21 = [[NSMutableAttributedString alloc] initWithString:@"8⭐️"
                                      attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                                   NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                                   NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label21.attributedText = scoreAttributeString21;
    [self.view addSubview:label21];
    
    CGFloat x26 = x25 + pointLabelWidth + paddingLabel;
    CGFloat y26 = currentTop;
    HelpCharacterView *label22 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x26, y26, descriptionLabelWidth, cellHeight)];
    label22.content = @"Three Of A Kind";
    label22.textColor = [UIColor blackColor];
    [self.view addSubview:label22];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    
    // 第三行
    CGFloat x31 = winSize.width * pokerRatio - cellWidth;
    CGFloat y31 = currentTop;
    HelpPokerView *p31 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x31, y31, cellWidth, cellHeight)];
    p31.rank = 3;
    p31.suit = @"";
    [self.view addSubview:p31];
    
    CGFloat x32 = x31 - cellWidth - paddingPoker;
    CGFloat y32 = currentTop;
    HelpPokerView *p32 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x32, y32, cellWidth, cellHeight)];
    p32.rank = 3;
    p32.suit = @"";
    [self.view addSubview:p32];
    
    CGFloat x33 = x32 - cellWidth - paddingPoker;
    CGFloat y33 = currentTop;
    HelpPokerView *p33 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x33, y33, cellWidth, cellHeight)];
    p33.rank = 3;
    p33.suit = @"";
    [self.view addSubview:p33];
    
    CGFloat x34 = x33 - cellWidth - paddingPoker;
    CGFloat y34 = currentTop;
    HelpPokerView *p34 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x34, y34, cellWidth, cellHeight)];
    p34.rank = 3;
    p34.suit = @"";
    [self.view addSubview:p34];
    
    CGFloat x35 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y35 = currentTop;
    UILabel *label31 = [[UILabel alloc] initWithFrame:CGRectMake(x35, y35, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString31 = [[NSMutableAttributedString alloc] initWithString:@"16⭐️"
                                   attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                                NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                                NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label31.attributedText = scoreAttributeString31;
    [self.view addSubview:label31];
    
    CGFloat x36 = x35 + pointLabelWidth + paddingLabel;
    CGFloat y36 = currentTop;
    HelpCharacterView *label32 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x36, y36, descriptionLabelWidth, cellHeight)];
    label32.content = @"Four Of A Kind";
    label32.textColor = [UIColor blackColor];
    [self.view addSubview:label32];

    currentTop = currentTop + cellHeight + paddingHeight;
    
    
    // 第四行
    CGFloat x41 = winSize.width * pokerRatio - cellWidth;
    CGFloat y41 = currentTop;
    HelpPokerView *p41 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x41, y41, cellWidth, cellHeight)];
    p41.rank = 0;
    p41.suit = @"♣︎";
    [self.view addSubview:p41];
    
    CGFloat x42 = x41 - cellWidth - paddingPoker;
    CGFloat y42 = currentTop;
    HelpPokerView *p42 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x42, y42, cellWidth, cellHeight)];
    p42.rank = 0;
    p42.suit = @"♣︎";
    [self.view addSubview:p42];
    
    CGFloat x43 = x42 - cellWidth - paddingPoker;
    CGFloat y43 = currentTop;
    HelpPokerView *p43 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x43, y43, cellWidth, cellHeight)];
    p43.rank = 0;
    p43.suit = @"♣︎";
    [self.view addSubview:p43];
    
    CGFloat x44 = x43 - cellWidth - paddingPoker;
    CGFloat y44 = currentTop;
    HelpPokerView *p44 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x44, y44, cellWidth, cellHeight)];
    p44.rank = 0;
    p44.suit = @"♦︎";
    //[self.view addSubview:p44];
    
    CGFloat x45 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y45 = currentTop;
    UILabel *label41 = [[UILabel alloc] initWithFrame:CGRectMake(x45, y45, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString41 = [[NSMutableAttributedString alloc] initWithString:@"4⭐️"
                           attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                        NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                        NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label41.attributedText = scoreAttributeString41;
    [self.view addSubview:label41];
    
    CGFloat x46 = x45 + pointLabelWidth + paddingLabel;
    CGFloat y46 = currentTop;
    HelpCharacterView *label42 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x46, y46, descriptionLabelWidth, cellHeight)];
    label42.content = @"3 Card Flush";
    label42.textColor = [UIColor blackColor];
    [self.view addSubview:label42];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    
    // 第5行
    CGFloat x51 = winSize.width * pokerRatio - cellWidth;
    CGFloat y51 = currentTop;
    HelpPokerView *p51 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x51, y51, cellWidth, cellHeight)];
    p51.rank = 0;
    p51.suit = @"♠︎";
    [self.view addSubview:p51];
    
    CGFloat x52 = x51 - cellWidth - paddingPoker;
    CGFloat y52 = currentTop;
    HelpPokerView *p52 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x52, y52, cellWidth, cellHeight)];
    p52.rank = 0;
    p52.suit = @"♠︎";
    [self.view addSubview:p52];
    
    CGFloat x53 = x52 - cellWidth - paddingPoker;
    CGFloat y53 = currentTop;
    HelpPokerView *p53 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x53, y53, cellWidth, cellHeight)];
    p53.rank = 0;
    p53.suit = @"♠︎";
    [self.view addSubview:p53];
    
    CGFloat x54 = x53 - cellWidth - paddingPoker;
    CGFloat y54 = currentTop;
    HelpPokerView *p54 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x54, y54, cellWidth, cellHeight)];
    p54.rank = 0;
    p54.suit = @"♠︎";
    [self.view addSubview:p54];
    
    CGFloat x55 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y55 = currentTop;
    UILabel *label51 = [[UILabel alloc] initWithFrame:CGRectMake(x55, y55, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString51 = [[NSMutableAttributedString alloc] initWithString:@"8⭐️"
                               attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                            NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                            NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label51.attributedText = scoreAttributeString51;
    [self.view addSubview:label51];
    
    CGFloat x56 = x55 + pointLabelWidth + paddingLabel;
    CGFloat y56 = currentTop;
    HelpCharacterView *label52 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x56, y56, descriptionLabelWidth, cellHeight)];
    label52.content = @"4 Card Flush";
    label52.textColor = [UIColor blackColor];
    [self.view addSubview:label52];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    
    // 第6行
    CGFloat x61 = winSize.width * pokerRatio - cellWidth;
    CGFloat y61 = currentTop;
    HelpPokerView *p61 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x61, y61, cellWidth, cellHeight)];
    p61.rank = 3;
    p61.suit = @"";
    [self.view addSubview:p61];
    
    CGFloat x62 = x61 - cellWidth - paddingPoker;
    CGFloat y62 = currentTop;
    HelpPokerView *p62 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x62, y62, cellWidth, cellHeight)];
    p62.rank = 2;
    p62.suit = @"";
    [self.view addSubview:p62];
    
    CGFloat x63 = x62 - cellWidth - paddingPoker;
    CGFloat y63 = currentTop;
    HelpPokerView *p63 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x63, y63, cellWidth, cellHeight)];
    p63.rank = 1;
    p63.suit = @"";
    [self.view addSubview:p63];
    
    CGFloat x64 = x63 - cellWidth - paddingPoker;
    CGFloat y64 = currentTop;
    HelpPokerView *p64 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x64, y64, cellWidth, cellHeight)];
    p64.rank = 0;
    p64.suit = @"♦︎";
    //[self.view addSubview:p64];
    
    CGFloat x65 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y65 = currentTop;
    UILabel *label61 = [[UILabel alloc] initWithFrame:CGRectMake(x65, y65, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString61 = [[NSMutableAttributedString alloc] initWithString:@"6⭐️"
                           attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                        NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                        NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label61.attributedText = scoreAttributeString61;
    [self.view addSubview:label61];
    
    CGFloat x66 = x65 + pointLabelWidth + paddingLabel;
    CGFloat y66 = currentTop;
    HelpCharacterView *label62 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x66, y66, descriptionLabelWidth, cellHeight)];
    label62.content = @"3 Card Straight";
    label62.textColor = [UIColor blackColor];
    [self.view addSubview:label62];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    // 第7行
    CGFloat x71 = winSize.width * pokerRatio - cellWidth;
    CGFloat y71 = currentTop;
    HelpPokerView *p71 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x71, y71, cellWidth, cellHeight)];
    p71.rank = 13;
    p71.suit = @"";
    [self.view addSubview:p71];
    
    CGFloat x72 = x71 - cellWidth - paddingPoker;
    CGFloat y72 = currentTop;
    HelpPokerView *p72 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x72, y72, cellWidth, cellHeight)];
    p72.rank = 12;
    p72.suit = @"";
    [self.view addSubview:p72];
    
    CGFloat x73 = x72 - cellWidth - paddingPoker;
    CGFloat y73 = currentTop;
    HelpPokerView *p73 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x73, y73, cellWidth, cellHeight)];
    p73.rank = 11;
    p73.suit = @"";
    [self.view addSubview:p73];
    
    CGFloat x74 = x73 - cellWidth - paddingPoker;
    CGFloat y74 = currentTop;
    HelpPokerView *p74 = [[HelpPokerView alloc] initWithFrame:CGRectMake(x74, y74, cellWidth, cellHeight)];
    p74.rank = 10;
    p74.suit = @"";
    [self.view addSubview:p74];
    
    CGFloat x75 = winSize.width * pokerRatio + paddingLabel;
    CGFloat y75 = currentTop;
    UILabel *label71 = [[UILabel alloc] initWithFrame:CGRectMake(x75, y75, pointLabelWidth, cellHeight)];
    NSMutableAttributedString *scoreAttributeString71 = [[NSMutableAttributedString alloc] initWithString:@"12⭐️"
                           attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor],
                                        NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:currentFontSize],
                                        NSParagraphStyleAttributeName:scoreParagraphStyle}];
    label71.attributedText = scoreAttributeString71;
    [self.view addSubview:label71];
    
    CGFloat x76 = x75 + pointLabelWidth + paddingLabel;
    CGFloat y76 = currentTop;
    HelpCharacterView *label72 = [[HelpCharacterView alloc] initWithFrame:CGRectMake(x76, y76, descriptionLabelWidth, cellHeight)];
    label72.content = @"4 Card Straight";
    label72.textColor = [UIColor blackColor];
    [self.view addSubview:label72];
    
    currentTop = currentTop + cellHeight + paddingHeight;
    
    // 返回按钮
    currentTop += winSize.height * 0.05f;
    CGFloat returnBtnHeight = winSize.height * 0.08f;
    CGFloat returnBtnWidth = returnBtnHeight * 4.0f;
    UIButton *returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(winSize.width/2.0f-returnBtnWidth/2.0f, currentTop, returnBtnWidth, returnBtnHeight)];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"long-home"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage imageNamed:@"long-home-pressed"] forState:UIControlStateHighlighted];
    [returnBtn addTarget:self action:@selector(returnToMain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnBtn];
    
    // 设置背景
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)returnToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
