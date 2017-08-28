//
//  ActivityView.m
//  FanbaMobileApp
//
//  Created by user on 15/3/27.
//
//
#import "LaunchIntroductionView.h"
#import "ActivityView.h"
#import "LLARingSpinnerView.h"
#import "AppDelegate.h"

#define ACTIVITY_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define ACTIVITY_WIDTH [[UIScreen mainScreen]bounds].size.width

@interface ActivityView ()

@property (nonatomic, strong) LLARingSpinnerView *spinnerView;
@property (nonatomic, assign) AppDelegate* appDelegate;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) NSInteger countShowNum;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation ActivityView

+(ActivityView *)shareAcctivity
{
    static ActivityView *mainActivityView = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        mainActivityView = [[ActivityView alloc] init];
    });
    
    return mainActivityView;
}

-(id)init
{
    CGRect  frame=CGRectMake(0, 0,ACTIVITY_WIDTH, ACTIVITY_HEIGHT);
    self=[super initWithFrame:frame];
    if (self) {
        //self.backgroundColor=RGBA_COLOR(0.3,0.3, 0.3, 0.5);
//        self.spinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectZero];
//        self.spinnerView.bounds = CGRectMake(0, 0, 40, 40);
//        self.spinnerView.tintColor = [UIColor colorWithRed:215.f/255 green:49.f/255 blue:69.f/255 alpha:1];
//        self.spinnerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        [self addSubview:self.spinnerView];
        UIView * _waitingIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0,80,80)];
        [_waitingIcon setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
        [_waitingIcon setBackgroundColor:[UIColor blackColor]];
        [_waitingIcon setAlpha:0.6];
        [_waitingIcon.layer setCornerRadius:5];
        [self addSubview:_waitingIcon];
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [_indicatorView setFrame:CGRectMake(0,0,12,12)];
        [_indicatorView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
        [self addSubview:_indicatorView];
        
        
        _countShowNum=0;
        
//        _loadingImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,110,123)];
//        
//        NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:10];
//        for (int i=1;i<11;i++) {
//            UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"londing%d",i]];
//            [array addObject:image];
//        }
//        _loadingImageView.animationImages=array;
//        _loadingImageView.animationDuration=0.9;
//        [_loadingImageView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
//        
//        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_loadingImageView.frame)+10,ACTIVITY_WIDTH,15)];
//        label.font=[UIFont systemFontOfSize:17.0];
//        label.textAlignment=NSTextAlignmentCenter;
//        label.textColor=[UIColor colorWithRed:253 green:143 blue:0 alpha:1.0];
//        label.text=@"玩命加载中...";
//        [self addSubview:label];
//
//        [self addSubview:_loadingImageView];
        
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(_indicatorView.frame)+40,ACTIVITY_WIDTH,15)];
        label.font=[UIFont systemFontOfSize:17.0];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        label.text=@"加载中...";
        [self addSubview:label];

        
    }
    return self;
}

-(void)showActivity
{
    
    self.hidden=NO;
    //[_loadingImageView startAnimating];
    if (!_indicatorView.isAnimating) {
        [_indicatorView startAnimating];
    }
//    if (!_loadingImageView.isAnimating) {
//        [_loadingImageView startAnimating];
//    }
    if (self.superview==nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window  addSubview:self];
    }
   
    _countShowNum++;
    //[_spinnerView startAnimating];
   
    
    //新加将引导图加到loading框上面
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    for (UIView *subView in window.subviews) {
        if ([subView isKindOfClass:[LaunchIntroductionView class]]) {
            [window bringSubviewToFront:subView];
        }
    }
}
-(void)stopImageAnimation
{
    [_loadingImageView stopAnimating];
    //[_spinnerView stopAnimating];
   
}

-(void)hiddeActivity
{
     //[self performSelector:@selector(stopImageAnimation) withObject:nil afterDelay:0.5];
   
    _countShowNum--;
    if (_countShowNum<0) {
        _countShowNum=0;
    }
    if (_countShowNum==0) {
        self.hidden=YES;
        [self removeFromSuperview];
        [_indicatorView stopAnimating];
//        [_loadingImageView stopAnimating];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
