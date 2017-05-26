//
//  AchivementView.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/27.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AchivementView : UIView

@property (nonatomic, strong) NSString *cardBackImageStr;
@property (nonatomic, strong) NSString *achivementDiscription;

+ (instancetype)achivementWithPosition:(CGPoint)position
                             sideWidth:(CGFloat)sideWidth
                            sideHeight:(CGFloat)sideHeight
                          cardBackImageStr:(NSString *)cardBackImageStr
                     achivementDiscription:(NSString *)achivementDescription;

@end
