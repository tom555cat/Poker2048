//
//  CardBackScrollViewController.h
//  Tlm2048_1
//
//  Created by tom555cat on 15/12/13.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "PokerGameViewController.h"

@protocol ChooseCardBackDelegate <NSObject>

- (void)changeBackgroundWithTag:(NSInteger)tag;

@end

@interface CardBackScrollViewController : UIViewController

@property (nonatomic, weak) id <ChooseCardBackDelegate> delegate;
@property (weak, nonatomic) PokerGameViewController *pokerGameViewController;
@end
