//
//  MyToast.h
//  FanbaMobileApp
//
//  Created by user on 15/7/29.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyToast : NSObject
{
    NSString *text;
    UIButton *contentView;
    CGFloat  duration;
}

+ (void)showWithText:(NSString *) text_
            duration:(CGFloat)duration_;

+ (void)onekeyloan_showWithText:(NSString *)text_
                       duration:(CGFloat)duration_ y:(CGFloat)y;

@end
