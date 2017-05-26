//
//  HelpPokerView.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/3.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpPokerView : UIButton

@property (nonatomic) NSInteger rank;
@property (nonatomic, strong) NSString *suit;

- (instancetype)initWithFrame:(CGRect)frame;

@end
