//
//  MTERootViewController.m
//  MultipleTruncationExample
//
//  Created by Daniel Hammond on 11/12/13.
//  Copyright (c) 2013 Daniel Hammond. All rights reserved.
//

#import "MTERootViewController.h"
#import "MTETextView.h"

@interface MTERootViewController ()

@property (nonatomic, weak) MTETextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *textViewWidthConstraint;

@end

@implementation MTERootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MTETextView *textView = [MTETextView new];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:textView];
    self.textView = textView;
    
    UISlider *slider = [UISlider new];
    slider.value = 1.0;
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    id top = self.topLayoutGuide;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(top, textView, slider);
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    self.textViewWidthConstraint = [NSLayoutConstraint constraintWithItem:textView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0];
    [self.view addConstraint:self.textViewWidthConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[slider]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-[textView(==30)]-[slider]|" options:0 metrics:nil views:views]];
}

- (void)sliderAction:(UISlider *)slider
{
    [self.textViewWidthConstraint setConstant:-((1.0 - slider.value) * CGRectGetWidth(self.view.bounds))];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
