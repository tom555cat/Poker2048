//
//  DirectViewController.m
//  Poker2048
//
//  Created by tom555cat on 16/3/23.
//  Copyright © 2016年 tom555cat. All rights reserved.
//

#import "DirectViewController.h"
#import "DirectView.h"

@interface DirectViewController ()

@end

@implementation DirectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)setup
{
    DirectView *directView = [[DirectView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:directView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
