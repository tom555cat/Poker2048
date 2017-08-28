//
//  ChangeTablebar.m
//  CashLoan
//
//  Created by user on 16/9/5.
//  Copyright © 2016年 user. All rights reserved.
//

#import "ChangeTablebar.h"
#import "MytableBarVC.h"
#import "AppDelegate.h"

@implementation ChangeTablebar

+(void)showTableBar
{
    AppDelegate *appDeleagte=(AppDelegate *)[UIApplication sharedApplication].delegate;
    MytableBarVC *tabBarVC=(MytableBarVC *)appDeleagte.window.rootViewController;
    if (tabBarVC.tabBarHidden) {
        [tabBarVC setTabBarHidden:NO animated:NO];
    }
    
}
+(void)hiddenTableBar
{
    AppDelegate *appDeleagte=(AppDelegate *)[UIApplication sharedApplication].delegate;
    MytableBarVC *tabBarVC=(MytableBarVC *)appDeleagte.window.rootViewController;
    if (!tabBarVC.tabBarHidden) {
        [tabBarVC setTabBarHidden:YES animated:NO];
    }
    
}


@end
