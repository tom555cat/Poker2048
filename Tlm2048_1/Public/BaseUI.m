
#import "UIColor+MyColor.h"
#import "BaseUI.h"



@implementation BaseUI

+(UILabel *)newLabelWithFrame:(CGRect)frame titleStr:(NSString *)str andFont:(UIFont *)font andColor:(UIColor *)color
{
    UILabel *moreLabel=[[UILabel alloc]initWithFrame:frame];
    moreLabel.font=font;
    moreLabel.textColor=color;
    moreLabel.textAlignment=NSTextAlignmentCenter;
    moreLabel.backgroundColor=[UIColor clearColor];
    //moreLabel.userInteractionEnabled=YES;
    moreLabel.text=str;
    return moreLabel;
}

+(UIButton *)newButtonWithFrame:(CGRect)frame normaltitleStr:(NSString *)titleStr  andNormalTitleCololr:(UIColor *)clolor andNormalImageName:(NSString *)imageName andHiglightImageName:(NSString *)higlightImageName
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:titleStr forState:UIControlStateNormal];
    [button setTitleColor:clolor forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:higlightImageName] forState:UIControlStateHighlighted];
    
    return button;
}

+(void)setImageView:(UIImageView *)imageView withImage:(NSString *)str
{
    UIImage *image=[UIImage imageNamed:str];
    CGSize imageSize=[image size];
    
    CGRect frame=imageView.frame;
    float fx=imageSize.width/SCREEN_WIDTH;
    float with=imageSize.width;
    float heigth=imageSize.height;
    if (fx>1) {
        if (with>375) {
            with=imageSize.width/fx;
            heigth=imageSize.height/fx;
        }
        else
        {
            fx=imageSize.width/375;
            with=SCREEN_WIDTH*fx;
            heigth=imageSize.height*fx;
        }
        
    }
    frame=CGRectMake((SCREEN_WIDTH-with)/2,frame.origin.y,with, heigth);
    [imageView setFrame:frame];
    imageView.image=image;
}

+(CGSize)showStr:(NSString *)showStr andFontSize:(CGFloat)fontFloat
{
    CGSize fontSize=[showStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontFloat]}];
    return fontSize;
    
}

+(UIImage *)getBarImageWithColor:(UIColor *)color andSize:(CGSize)size
{
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0,(size.width)*2,size.height*2)];
    view.backgroundColor=color;
    
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIButton *)newCheckBoxWithFrame:(CGRect )frame andNormalImag:(NSString *)norImage selectedImage:(NSString *)selectImage
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    UIImage *image=[UIImage imageNamed:norImage];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0,0,frame.size.height-image.size.height,0)];
    
    if (norImage!=nil) {
        [button setImage:[UIImage imageNamed:norImage] forState:UIControlStateNormal];
    }
    if (selectImage!=nil) {
        [button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    }
    
    return button;
}

+(NSAttributedString *)textOrgin:(NSString *)orginStr andTarget:(NSArray *)targetStrAry normalColor:(UIColor *)norColor tagetColor:(NSArray*)tagetColor originFontSize:(float )orginSize targetFontArray:(NSArray *)fontSizeArray
{
    NSDictionary *attriDict1=@{
                               NSForegroundColorAttributeName: norColor,
                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:orginSize]
                               };
    NSMutableAttributedString *totalStr=[[NSMutableAttributedString alloc]initWithString:orginStr attributes:attriDict1];
    
    NSInteger count=[targetStrAry count];
    
    for (int i=0;i<count;i++) {
        NSDictionary *attriDict2=@{
                                   NSForegroundColorAttributeName: [tagetColor objectAtIndex:i],
                                   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:[[fontSizeArray objectAtIndex:i] floatValue]]
                                   };
        [totalStr addAttributes:attriDict2 range:[orginStr rangeOfString:[targetStrAry objectAtIndex:i]options:NSBackwardsSearch]];
    }
    
    return totalStr;
}

+ (void)callVC:(UIViewController *)VC phone:(NSString *)phone
{
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.message  = [NSString stringWithFormat:@"立即拨打客服电话\n%@",phone];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *pp = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", pp]]];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [VC presentViewController:alert animated:YES completion:nil];
}

+(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font andLineSpace:(float)lineSpace {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing =lineSpace; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSForegroundColorAttributeName:UIColorFromRGB(0x7a7a80),
                          };
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    label.attributedText = attributeStr;
}

+(UIButton *)newSubmitBtnWithStartY:(float)localY
{
    UIButton *submit=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage=[UIImage imageNamed:@"redpic"];
     [submit setFrame:CGRectMake((SCREEN_WIDTH-btnImage.size.width*SCREEN_SCALE)/2,localY,btnImage.size.width*SCREEN_SCALE,btnImage.size.height*SCREEN_SCALE)];
    
    return submit;
}

+(UIButton *)newSubmitBtnWithStartY:(float)localY imageName:(NSString *)imageName title:(NSString*)title titleColor:(UIColor *)color OnView:(UIView *)view
{
    UIButton *submit=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage=[UIImage imageNamed:imageName];
    [submit setFrame:CGRectMake((SCREEN_WIDTH-btnImage.size.width*SCREEN_SCALE)/2,localY,btnImage.size.width*SCREEN_SCALE,btnImage.size.height*SCREEN_SCALE)];
    
    [submit setTitle:title forState:UIControlStateNormal];
    [submit setTitleColor:color forState:UIControlStateNormal];
    
    [view addSubview:submit];
    
    return submit;
}

+(UIButton *)newSubmitBtnWithStartY:(float)localY imageName:(NSString *)imageName title:(NSString*)title titleColor:(UIColor *)titleColor normalBackgroudImage:(NSString *)backImageName enabled:(BOOL) isEnable OnView:(UIView *)view
{
    UIButton *submit=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage=[UIImage imageNamed:imageName];
    [submit setFrame:CGRectMake((SCREEN_WIDTH-btnImage.size.width*SCREEN_SCALE)/2,localY,btnImage.size.width*SCREEN_SCALE,btnImage.size.height*SCREEN_SCALE)];
    
    [submit setTitle:title forState:UIControlStateNormal];
    [submit setTitleColor:titleColor forState:UIControlStateNormal];
    
    submit.enabled = isEnable;
    submit.userInteractionEnabled = isEnable;
    [submit setBackgroundImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
    
    [view addSubview:submit];
    
    return submit;
}



@end
