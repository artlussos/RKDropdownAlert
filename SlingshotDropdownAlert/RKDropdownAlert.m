//
//  RKDropdownAlert.m
//  SlingshotDropdownAlert
//
//  Created by Richard Kim on 8/26/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

/*

 Copyright (c) 2014 Choong-Won Richard Kim <cwrichardkim@gmail.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*/

#import "RKDropdownAlert.h"

@interface RKDropdownAlert()
@property (nonatomic, strong) UILabel *rkTitleLabel;
@property (nonatomic, strong) UILabel *rkMessageLabel;
@end

@implementation RKDropdownAlert

+ (UIColor*)defaultTextColor
{
    return[UIColor whiteColor];
}

+ (UIColor*)defaultBackgroundColor
{
    return[UIColor darkGrayColor];
}

+ (CGFloat)defaultHeight
{
    return 90;
}

+ (CGFloat)defaultFontSize
{
    return 14.0;
}

+ (CGFloat)defaultShowTime
{
    return 3.0;
}

+ (CGFloat)defaultAnimationTime
{
    return 0.3;
}

+ (UIFont*)defaultFont
{
    return [UIFont boldSystemFontOfSize:[RKDropdownAlert defaultFontSize]];
}

- (CGRect)titleFrame:(CGRect)frame
{
    return CGRectMake(10,
                      CGRectGetHeight([UIApplication sharedApplication].statusBarFrame),
                      CGRectGetWidth(frame) - (2 * 10),
                      20);
}

- (CGRect)messageFrame:(CGRect)frame
{
    return CGRectMake(10,
                      CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 20,
                      CGRectGetWidth(frame) - (2 * 10),
                      20);
}

- (void)createTitleLabel:(CGRect)frame
{
    _rkTitleLabel = [[UILabel alloc]initWithFrame:[self titleFrame:frame]];

    [_rkTitleLabel setFont:[RKDropdownAlert defaultFont]];
    _rkTitleLabel.textColor = [RKDropdownAlert defaultTextColor];
    _rkTitleLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_rkTitleLabel];
}

- (void)createMessageLabel:(CGRect)frame
{
    _rkMessageLabel = [[UILabel alloc]initWithFrame:[self messageFrame:frame]];

    [_rkMessageLabel setFont:[RKDropdownAlert defaultFont]];
    _rkMessageLabel.textColor = [RKDropdownAlert defaultTextColor];
    _rkMessageLabel.textAlignment = NSTextAlignmentCenter;

    _rkMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _rkMessageLabel.numberOfLines = 1;

    [self addSubview:_rkMessageLabel];
}

- (void)defaultValues
{
    _textColor = [RKDropdownAlert defaultTextColor];
    _displayTime = [RKDropdownAlert defaultShowTime];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0,
                                          -[RKDropdownAlert defaultHeight],
                                          [[UIScreen mainScreen]bounds].size.width,
                                          [RKDropdownAlert defaultHeight])];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [RKDropdownAlert defaultBackgroundColor];
        [self defaultValues];
        [self createTitleLabel:frame];
        [self createMessageLabel:frame];

        [self addTarget:self action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)viewWasTapped:(UIButton *)alertView
{
    /*
     eg: say you have a messaging component in your app and someone sends a message to the user.
     Here is where you would write the method that takes the user
     to the conversation with the person that sent them the message
     */

    //%%% this hides the view, you can remove this if you don't want the view to disappear on tap
    [self hideView:alertView];
}

-(void)hideView:(UIButton *)alertView
{
    if (alertView) {
        [UIView animateWithDuration:[RKDropdownAlert defaultAnimationTime] animations:^{
            CGRect frame = alertView.frame;
            frame.origin.y = -[RKDropdownAlert defaultHeight];
            alertView.frame = frame;
        }];
        [self performSelector:@selector(removeView:) withObject:alertView afterDelay:[RKDropdownAlert defaultAnimationTime]];
    }
}

- (void)addView
{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];

    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window.rootViewController.view addSubview:self];
            break;
        }
    }
}

-(void)removeView:(UIButton *)alertView
{
    if (alertView){
        [alertView removeFromSuperview];
    }
}

- (void)messageText
{
    if (self.message) {
        self.rkMessageLabel.text = self.message;
        if (![self isMessageTextOneLine]) {
            self.rkMessageLabel.numberOfLines = 2;

            CGRect rect = self.rkMessageLabel.frame;
            rect.size.height *= 2;
            self.rkMessageLabel.frame = rect;
        }
    }
    else {
        CGRect rect = self.rkTitleLabel.frame;
        rect.origin.y = [RKDropdownAlert defaultHeight]/2;
        self.rkTitleLabel.frame = rect;
    }
}

-(void)show
{
    self.rkTitleLabel.text = self.title;
    [self messageText];

    self.rkTitleLabel.textColor = self.textColor;
    self.rkMessageLabel.textColor = self.textColor;

    if (!self.superview){
        [self addView];
    }

    [UIView animateWithDuration:[RKDropdownAlert defaultAnimationTime] animations:^{
        CGRect frame = self.frame;
        frame.origin.y = 0;
        self.frame = frame;
    }];

    [self performSelector:@selector(hideView:)
               withObject:self
               afterDelay:self.displayTime + [RKDropdownAlert defaultAnimationTime]];
}

-(BOOL)isMessageTextOneLine
{
    CGSize size = [self.rkMessageLabel.text sizeWithAttributes:
                   @{NSFontAttributeName:[UIFont systemFontOfSize:[RKDropdownAlert defaultFontSize]]}];

    return size.width > CGRectGetWidth(self.rkMessageLabel.frame) ? NO : YES;
}

@end
