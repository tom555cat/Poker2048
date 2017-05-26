//
//  F3HPokerView.m
//  Tlm2048
//
//  Created by tom555cat on 15/9/24.
//  Copyright © 2015年 tom555cat. All rights reserved.
//

#import "PokerView.h"

#import <QuartzCore/QuartzCore.h>
#import "F3HTileAppearanceProvider.h"

@interface PokerView ()

@property (nonatomic, readonly) UIColor *defaultBackgroundColor;
@property (nonatomic, readonly) UIColor *defaultNumberColor;

@property (nonatomic, strong) UILabel *pokerLabel;
@property (nonatomic) PokerColor pokerColor;
@property (nonatomic) PokerNumber pokerNumber;


@end

@implementation PokerView

+ (instancetype)pokerForPosition:(CGPoint)position
                       sideWidth:(CGFloat)sideWidth
                      sideHeight:(CGFloat)sideHeight
                      pokerColor:(PokerColor)pokerColor
                     pokerNumber:(PokerNumber)pokerNumber
                    cornerRadius:(CGFloat)cornerRadius
{
    PokerView *poker = [[[self class] alloc] initWithFrame:CGRectMake(position.x, position.y, sideWidth, sideHeight)];
    poker.pokerLabel.textColor = poker.defaultNumberColor;
    poker.tilePokerColor = pokerColor;
    poker.tilePokerNumber = pokerNumber;
    //poker.layer.cornerRadius = cornerRadius;
    poker.imageName = [PokerView setImageNameWithPokerColor:pokerColor pokerNumber:pokerNumber];
    NSLog(@"%@", poker.imageName);
    // 设置poker对应的图片
    poker.imageView.image = [UIImage imageNamed:poker.imageName];
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, M_PI, 0.0f, 1.0f, 0.0f);
    //poker.imageView.layer.transform = transform;
    return poker;
}

- (instancetype)initWithPokerColor:(PokerColor)pokerColor
                       pokerNumber:(PokerNumber)pokerNumber
{
    self = [super init];
    
    if (!self) {
        self.pokerColor = pokerColor;
        self.pokerNumber = pokerNumber;
        self.imageName = [PokerView setImageNameWithPokerColor:pokerColor pokerNumber:pokerNumber];
        self.imageView.image = [UIImage imageNamed:self.imageName];
    }
    
    return self;
}

// 设置该poker对应的图片的路径名字
+ (NSMutableString *)setImageNameWithPokerColor:(PokerColor)pokerColor
                                    pokerNumber:(PokerNumber)pokerNumber
{
    NSMutableString *name = [[NSMutableString alloc] init];
    // 设置花色前缀
    switch (pokerColor) {
        case PokerColorHeart:
            [name appendString:@"HT_"];
            break;
        case PokerColorSpade:
            [name appendString:@"HTB_"];
            break;
        case PokerColorDiamond:
            [name appendString:@"FP_"];
            break;
        case PokerColorClub:
            [name appendString:@"MH_"];
            break;
        default:
            break;
    }
    
    switch (pokerNumber) {
        case PokerNumber1:
            [name appendString:@"A"];
            break;
        case PokerNumber2:
            [name appendString:@"2"];
            break;
        case PokerNumber3:
            [name appendString:@"3"];
            break;
        case PokerNumber4:
            [name appendString:@"4"];
            break;
        case PokerNumber5:
            [name appendString:@"5"];
            break;
        case PokerNumber6:
            [name appendString:@"6"];
            break;
        case PokerNumber7:
            [name appendString:@"7"];
            break;
        case PokerNumber8:
            [name appendString:@"8"];
            break;
        case PokerNumber9:
            [name appendString:@"9"];
            break;
        case PokerNumber10:
            [name appendString:@"10"];
            break;
        case PokerNumber11:
            [name appendString:@"J"];
            break;
        case PokerNumber12:
            [name appendString:@"Q"];
            break;
        case PokerNumber13:
            [name appendString:@"K"];
            break;
        default:
            break;
    }
    
    //[name appendString:@".png"];
    return name;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    // 插入Poker图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           frame.size.width,
                                                                           frame.size.height)];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 3.0;
    imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:imageView];
    self.imageView = imageView;
    
    return self;
}

- (void)setDelegate:(id<F3HTileAppearanceProviderProtocol>)delegate
{
    _delegate = delegate;
    if (delegate) {
        //self.backgroundColor = [delegate tileColorForValue:self.tilePokerColor];
        //self.pokerLabel.textColor = [delegate numberColorForValue:self.tilePokerNumber];
        //self.pokerLabel.font = [delegate fontForNumbers];
    }
}

- (void)setTilePokerColor:(PokerColor)tilePokerColor
{
    _tilePokerColor = tilePokerColor;
    self.pokerColor = tilePokerColor;
}

- (void)setTilePokerNumber:(PokerNumber)tilePokerNumber
{
    _tilePokerNumber = tilePokerNumber;
    //self.pokerLabel.text = [NSString stringWithFormat:@"%d", self.tilePokerNumber];
    //self.pokerLabel.text = [@(self.tilePokerNumber) stringValue];
    //elf.pokerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    self.pokerNumber = tilePokerNumber;
    NSLog(@"poker label text is: %ld", (long)self.tilePokerNumber);
}

- (UIColor *)defaultBackgroundColor
{
    return [UIColor lightGrayColor];
}

- (UIColor *)defaultNumberColor
{
    return [UIColor blackColor];
}

#pragma mark - drawing

#define CORNER_FONT_STANDARD_HEIGHT 100.0
#define CORNER_RADIUS 10.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // 设置扑克view圆角边缘
    UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    [roundRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    // 设置扑克黑色轮廓
    [[UIColor blackColor] setStroke];
    [roundRect stroke];
}
 */



@end
