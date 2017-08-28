//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseUI : NSObject

+(UILabel *)newLabelWithFrame:(CGRect)frame titleStr:(NSString *)str andFont:(UIFont *)font andColor:(UIColor *)color;

+(UIButton *)newButtonWithFrame:(CGRect)frame normaltitleStr:(NSString *)titleStr  andNormalTitleCololr:(UIColor *)clolor andNormalImageName:(NSString *)imageName andHiglightImageName:(NSString *)higlightImageName;

+(void)setImageView:(UIImageView *)imageView withImage:(NSString *)str;

+(UIImage *)getBarImageWithColor:(UIColor *)color andSize:(CGSize)size;

+(CGSize)showStr:(NSString *)showStr andFontSize:(CGFloat)fontFloat;

+(UIButton *)newCheckBoxWithFrame:(CGRect )frame andNormalImag:(NSString *)norImage selectedImage:(NSString *)selectImage;

+(NSAttributedString *)textOrgin:(NSString *)orginStr andTarget:(NSArray *)targetStrAry normalColor:(UIColor *)norColor tagetColor:(NSArray*)tagetColor originFontSize:(float )orginSize targetFontArray:(NSArray *)fontSizeArray;

+ (void)callVC:(UIViewController *)VC phone:(NSString *)phone;

+(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font andLineSpace:(float)lineSpace;

+(UIButton *)newSubmitBtnWithStartY:(float)localY;

+(UIButton *)newSubmitBtnWithStartY:(float)localY imageName:(NSString *)imageName title:(NSString*)title titleColor:(UIColor *)color OnView:(UIView *)view;
+(UIButton *)newSubmitBtnWithStartY:(float)localY imageName:(NSString *)imageName title:(NSString*)title titleColor:(UIColor *)titleColor normalBackgroudImage:(NSString *)backImageName enabled:(BOOL) isEnable OnView:(UIView *)view;
@end
