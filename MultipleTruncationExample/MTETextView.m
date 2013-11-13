//
//  MTETextView.m
//  MultipleTruncationExample
//
//  Created by Daniel Hammond on 11/12/13.
//  Copyright (c) 2013 Daniel Hammond. All rights reserved.
//

#import "MTETextView.h"
#import "MTEFocusedTruncationRenderer.h"

@interface MTETextView ()

@property (nonatomic, strong) MTEFocusedTruncationRenderer *renderer;

@end

@implementation MTETextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _renderer = [MTEFocusedTruncationRenderer new];
        NSString *string = @"Four loko mustache Helvetica, Schlitz Carles polaroid 8-bit literally photo booth 3 wolf moon Tumblr put a bird on it Blue Bottle 90's fanny pack. Banjo Portland viral, trust fund post-ironic hoodie Thundercats raw denim. Deep v seitan Thundercats, typewriter sartorial small batch hashtag umami gastropub meggings Vice try-hard Pitchfork McSweeney's Banksy. Vegan cardigan butcher distillery wayfarers, 3 wolf moon blog gentrify kogi pork belly street art skateboard. Thundercats Carles next level semiotics quinoa. Aesthetic farm-to-table Odd Future ethnic sustainable Austin. Paleo +1 gentrify, Pitchfork vinyl PBR tousled cardigan sartorial";
        NSDictionary *attributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody] };
        _renderer.contents = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        _renderer.focusedRange = (NSRange){ 19, 9 };
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawingBounds = CGRectInset(rect, 10.0, 0.0);
    
    [[UIColor whiteColor] set];
    UIRectFill(rect);
    UIRectFrame(self.bounds);
    
    [bezierPath moveToPoint:(CGPoint){ 0.0, CGRectGetMinY(drawingBounds) - 10.0 }];
    [bezierPath addLineToPoint:(CGPoint){ 0.0, CGRectGetMaxY(drawingBounds) + 30.0 }];
    
    CGContextSaveGState(context);
    [[UIColor redColor] set];
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(CGRectGetMinX(drawingBounds), 0.0));
    [bezierPath stroke];
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(CGRectGetWidth(drawingBounds), 0.0));
    [bezierPath stroke];
    CGContextRestoreGState(context);
    [self.renderer drawInRect:drawingBounds];
}

@end
