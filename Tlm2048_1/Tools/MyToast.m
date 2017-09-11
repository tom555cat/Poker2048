//
//  MyToast.m
//  FanbaMobileApp
//
//  Created by user on 15/7/29.
//
//

#import "MyToast.h"

#define SPECIALWIDTG [[UIScreen mainScreen]bounds].size.width

@interface MyToast ()

-(id)initWithText:(NSString *)text_;
- (void)setDuration:(CGFloat) duration_;

- (void)dismisToast;
- (void)toastTaped:(UIButton *)sender_;

- (void)showAnimation;
- (void)hideAnimation;

- (void)show;

@end

@implementation MyToast

- (id)initWithText:(NSString *)text_{
    if (self = [super init]) {
        
        text = [text_ copy];
        
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SPECIALWIDTG-50*2, 30)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.adjustsFontSizeToFitWidth=YES;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = font;
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        
        contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textLabel.frame.size.width, textLabel.frame.size.height)];
        contentView.layer.cornerRadius = 5.0f;
        contentView.layer.borderWidth = 1.0f;
        contentView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        contentView.backgroundColor = [UIColor colorWithRed:0.2f
                                                      green:0.2f
                                                       blue:0.2f
                                                      alpha:0.75f];
        [contentView addSubview:textLabel];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [contentView addTarget:self
                        action:@selector(toastTaped:)
              forControlEvents:UIControlEventTouchDown];
        contentView.alpha = 0.0f;
        
        duration = 0.5;
        
    }
    return self;
}

-(void)dismisToast{
    [contentView removeFromSuperview];
}

-(void)toastTaped:(UIButton *)sender_{
    [self hideAnimation];
}

- (void)setDuration:(CGFloat) duration_{
    duration = duration_;
}

-(void)showAnimation{
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 1.0f;
    [UIView commitAnimations];
}

-(void)hideAnimation{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismisToast)];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    contentView.center = window.center;
    [window  addSubview:contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:duration];
}
+ (void)showWithText:(NSString *)text_
            duration:(CGFloat)duration_{
    dispatch_async(dispatch_get_main_queue(), ^{
        MyToast *toast = [[MyToast alloc] initWithText:text_];
        [toast setDuration:duration_];
        [toast show];
    });
   
}

+ (void)onekeyloan_showWithText:(NSString *)text_
            duration:(CGFloat)duration_ y:(CGFloat)y
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MyToast *toast = [[MyToast alloc] initWithText:text_];
        [toast setDuration:duration_];
        [toast showy:y];
    });
}

- (void)showy:(CGFloat)y{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint center = window.center;
    center.y = y;
    contentView.center = center;    
    [window  addSubview:contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:duration];
}


@end
