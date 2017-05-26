//
//  HelpCharacterView.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/4.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpCharacterView : UIView

@property (nonatomic, strong) NSString *content;
@property (nonatomic) UIColor *textColor;

- (instancetype)initWithFrame:(CGRect)frame;

@end
