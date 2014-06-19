//
//  IDNumPadView.m
//  IDD Dialer
//
//  Created by Raymond Lee on 13/3/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//
#import "IDNumPadView.h"
#import "MRoundedButton.h"

@interface IDNumPadView ()

@property(nonatomic) NSDictionary *keypadButtonsDict;

@end

@implementation IDNumPadView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setupButtons];
}

- (void)setupButtons {
    NSMutableArray *keyBtns = [NSMutableArray arrayWithCapacity:12];
    _keypadButtonsDict = [NSMutableDictionary dictionaryWithCapacity:12];

    NSInteger column = 3;
    NSInteger row = 4;
    CGFloat diameter = 75;
    CGFloat widthInterval = (self.frame.size.width - diameter * column - 28 * 2) / (column - 1);
    CGFloat heightInterval = (self.frame.size.height - diameter * row - 28 * 2) / (row - 1);
    CGFloat xx[column];
    CGFloat yy[row];
    
    static NSString * buttonId = @"phonePad";
    NSDictionary *appearanceProxy = @{kMRoundedButtonCornerRadius : @(diameter/2),
                                       kMRoundedButtonBorderWidth  : @2,
                                       kMRoundedButtonRestoreHighlightState : @YES,
                                       kMRoundedButtonBorderColor : [[UIColor blackColor] colorWithAlphaComponent:0.1],
                                       kMRoundedButtonBorderAnimationColor : [[UIColor blackColor] colorWithAlphaComponent:0.1],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimationColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [[UIColor blackColor] colorWithAlphaComponent:0.3],
                                       kMRoundedButtonForegroundAnimationColor : [UIColor whiteColor]};
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy forIdentifier:buttonId];
    
    NSDictionary * detialedSubDict  =@{@"1":@"",@"2":@"A B C",@"3":@"D E F",@"4":@"G H I",@"5": @"J K L", @"6": @"M N O", @"7": @"P Q R S", @"8": @"T U V", @"9": @"W X Y Z", @"0": @"+"};
    for (int i = 0; i < column; i++) {
        xx[i] = 28 + (diameter + widthInterval) * i;
    }
    for (int j = 0; j < row; j++) {
        yy[j] = 28 + (diameter + heightInterval) * j;
    }
    for (NSInteger index = 0; index < 12; index++) {
        CGFloat x;
        CGFloat y;
        switch (index) {
            case 1:
                x = xx[0];
                y = yy[0];
                break;
            case 2:
                x = xx[1];
                y = yy[0];
                break;
            case 3:
                x = xx[2];
                y = yy[0];
                break;
            case 4:
                x = xx[0];
                y = yy[1];
                break;
            case 5:
                x = xx[1];
                y = yy[1];
                break;
            case 6:
                x = xx[2];
                y = yy[1];
                break;
            case 7:
                x = xx[0];
                y = yy[2];
                break;
            case 8:
                x = xx[1];
                y = yy[2];
                break;
            case 9:
                x = xx[2];
                y = yy[2];
                break;
            case 10:
                x = xx[0];
                y = yy[3];
                break;
            case 0:
                x = xx[1];
                y = yy[3];
                break;
            case 11:
                x = xx[2];
                y = yy[3];
                break;
            default:
                x = 0;
                y = 0;
                break;
        }
        MRoundedButton *keyBtn = [MRoundedButton buttonWithFrame:CGRectMake(x, y, diameter, diameter) buttonStyle:MRoundedButtonSubtitle appearanceIdentifier:buttonId];
//        [keyBtn setBackgroundColor:[UIColor colorWithWhite:1.f alpha:.3f]];
        [[keyBtn textLabel] setFont:[UIFont fontWithName:@"Helvetica-Light" size:34.f]];
        [[keyBtn detailTextLabel] setFont:[UIFont fontWithName:@"Helvetica-Light" size:10.f]];
        
//        [keyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [keyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//        [[keyBtn layer] setCornerRadius:diameter / 2];
//        [[keyBtn layer] setBorderWidth:1.5];
//        [[keyBtn layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
//        [keyBtn setReversesTitleShadowWhenHighlighted:YES];
        [keyBtn setTag:index];
        id keyTitle;
        NSString * subTitle = detialedSubDict[[NSString stringWithFormat:@"%ld", (long)index]] ;
        if (index < 10) {
            keyTitle = @(index);
        } else if (index == 10) {
            keyTitle = @"*";
        } else if (index == 11) {
            keyTitle = @"#";
        }
        [[keyBtn textLabel] setText:[NSString stringWithFormat:@"%@", keyTitle]];
        [[keyBtn detailTextLabel] setText:subTitle];
        [keyBtn addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchDown];
        [keyBtn addTarget:self action:@selector(keyUp:) forControlEvents:UIControlEventTouchUpInside];
        [keyBtn addTarget:self action:@selector(keyUp:) forControlEvents:UIControlEventTouchUpOutside];
        if (index == 0) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
            [keyBtn addGestureRecognizer:longPress];
        }
        [keyBtns addObject:keyBtn];
        [self addSubview:keyBtn];
        [_keypadButtonsDict setValue:keyBtn forKey:[NSString stringWithFormat:@"key%@", @(index)]];
    }
}

- (UIImage *)backgroundImage {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:.9f alpha:.9f] CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

NSDate *dateTapped;
BOOL isLongPressed;

- (void)keyPressed:(MRoundedButton *)button {
    [button setBackgroundColor:[UIColor colorWithWhite:.8f alpha:.2f]];
    if (_textField && [_textField isEditing]) {
        if (button.tag == 0) {
            dateTapped = [NSDate date];
            isLongPressed = NO;
        }
        [_textField insertText:[[button textLabel] text]];
        if ([self.textField isKindOfClass:[UITextField class]])
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self.textField];
    }
}

- (void)keyUp:(MRoundedButton *)button {
    [button setBackgroundColor:[UIColor colorWithWhite:1.f alpha:.3f]];
}

- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    if (_textField && [_textField isEditing]) {
        if ([dateTapped timeIntervalSinceNow] < -1 && !isLongPressed) {
            [_textField deleteBackward];
            [_textField insertText:@"+"];
            if ([self.textField isKindOfClass:[UITextField class]])
                [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self.textField];
            isLongPressed = YES;
        }
    }
}

@end
