//
//  F3HPokerView.h
//  Tlm2048
//
//  Created by tom555cat on 15/9/24.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PokerModel.h"

@protocol F3HTileAppearanceProviderProtocol;

@interface PokerView : UIView

@property (nonatomic) PokerColor tilePokerColor;
@property (nonatomic) PokerNumber tilePokerNumber;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<F3HTileAppearanceProviderProtocol>delegate;
@property (nonatomic) NSMutableString *imageName;

+ (instancetype)pokerForPosition:(CGPoint)position
                      sideWidth:(CGFloat)sideWidth
                      sideHeight:(CGFloat)sideHeight
                      pokerColor:(PokerColor)pokerColor
                     pokerNumber:(PokerNumber)pokerNumber
                    cornerRadius:(CGFloat)cornerRadius;

- (instancetype)initWithPokerColor:(PokerColor)pokerColor
                       pokerNumber:(PokerNumber)pokerNumber;

@end
