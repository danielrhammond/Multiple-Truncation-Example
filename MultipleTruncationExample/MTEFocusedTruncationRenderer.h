//
//  MTEFocusedTruncationRenderer.h
//  MultipleTruncationExample
//
//  Created by Daniel Hammond on 11/12/13.
//  Copyright (c) 2013 Daniel Hammond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTEFocusedTruncationRenderer : NSObject

@property (nonatomic, strong) NSAttributedString *contents;
@property (nonatomic) NSRange focusedRange;

- (void)drawInRect:(CGRect)rect;

@end
