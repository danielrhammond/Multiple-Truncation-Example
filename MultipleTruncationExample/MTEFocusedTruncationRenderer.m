//
//  MTEFocusedTruncationRenderer.m
//  MultipleTruncationExample
//
//  Created by Daniel Hammond on 11/12/13.
//  Copyright (c) 2013 Daniel Hammond. All rights reserved.
//

#import "MTEFocusedTruncationRenderer.h"

@import CoreText;

@interface MTEFocusedTruncationRenderer () <NSLayoutManagerDelegate>

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) NSRange truncationRange;
@property (nonatomic) BOOL forceTailTruncationRange; // BOOL?

@end

@implementation MTEFocusedTruncationRenderer

- (id)init
{
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawInRect:(CGRect)rect
{
    NSUInteger length = self.textStorage.length;
    NSRange focusedRange = self.selectedRange;
    
    /*
     These next two lines aren't in the original demo code that was shown.
     
     This fixes a bug that happens when you shrink the view down to the point where it triggers the multiple truncation and then 
     increase the size again, because of your alternate glyph mapping (putting the ellipsis earlier in the string), it will never 
     expand back out and turn the middle-truncation off.
     
     In the talk he shrinks the textView but never increases the size again, so it might be a bug in the demo code that they very 
     carefully didn't show or there is another fix for this somewhere else in the code that isn't visible
     */
    
    [self.layoutManager invalidateGlyphsForCharacterRange:(NSRange){ 0, length } changeInLength:0 actualCharacterRange:NULL];
    [self.layoutManager ensureLayoutForCharacterRange:(NSRange){ 0, length }];
    
    self.textContainer.size = (CGSize){ CGRectGetWidth(rect), CGRectGetHeight(rect) };
    _truncationRange = (NSRange){ 0, 0 };
    _forceTailTruncationRange = false;
    
    if (length > 0) {
        NSRange glyphRange;
        CGRect bounds = CGRectZero;
        bounds.size = rect.size;
        
        if (NSMaxRange(focusedRange) > length) {
            focusedRange.length = length - focusedRange.location;
        }
        
        if (focusedRange.length > 0) {
            [self.layoutManager ensureLayoutForCharacterRange:(NSRange){ 0, NSMaxRange(focusedRange) }];
        } else {
            [self.layoutManager ensureLayoutForBoundingRect:bounds inTextContainer:self.textContainer];
        }
        
        glyphRange = [self.layoutManager glyphRangeForBoundingRect:bounds inTextContainer:self.textContainer];
        
        if (glyphRange.length > 0) {
            
            /*
             This has been changed from the code shown in the talk to compare the character range of the truncated glyphs
             to the known character range of our focused range. This is because when the ranges intersect the glyph range for 
             the focused character range is extended to represent all the glyphs that have been truncated making the check for overlap
             with the truncated range always true
             */
            
            NSRange tailTruncatedCharacterRange;
            
            self.textContainer.size = bounds.size;
            
            if (focusedRange.length > 0) {
                NSUInteger location = [self.layoutManager glyphIndexForCharacterAtIndex:focusedRange.location];
                NSRange glyphRange = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:location];
                tailTruncatedCharacterRange = [self.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
                
                if (NSIntersectionRange((NSRange){ 0, NSMaxRange(focusedRange) }, tailTruncatedCharacterRange).length > 0) {
                    // Focused range is truncated out
                    if (focusedRange.location > 1) {
                        NSString *string = [self.textStorage string];
                        
                        // Move back and make space for ellipsis
                        _truncationRange.location = [string rangeOfComposedCharacterSequenceAtIndex:(focusedRange.location-1)].location;
                        _truncationRange.length = focusedRange.location - _truncationRange.location;
                        
                        while ((_truncationRange.location > 0) && (NSIntersectionRange(focusedRange, tailTruncatedCharacterRange).length > 0)) {
                            _truncationRange.location = [string rangeOfComposedCharacterSequenceAtIndex:(_truncationRange.location - 1)].location;
                            _truncationRange.length = focusedRange.location - _truncationRange.location;
                            [self.layoutManager invalidateGlyphsForCharacterRange:(NSRange){ 0, length } changeInLength:0 actualCharacterRange:NULL];
                            [self.layoutManager ensureLayoutForCharacterRange:(NSRange){ 0, length }];
                            NSUInteger location = [self.layoutManager glyphIndexForCharacterAtIndex:focusedRange.location];
                            NSRange truncatedGlyphRange = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:location];
                            tailTruncatedCharacterRange = [self.layoutManager characterRangeForGlyphRange:truncatedGlyphRange actualGlyphRange:NULL];
                        }
                    } else {
                        _truncationRange = (NSRange){0, focusedRange.location};
                        [self.layoutManager invalidateGlyphsForCharacterRange:(NSRange){ 0, length } changeInLength:0 actualCharacterRange:NULL];
                        [self.layoutManager ensureLayoutForCharacterRange:(NSRange){ 0, length }];
                        NSUInteger location = [self.layoutManager glyphIndexForCharacterAtIndex:focusedRange.location];
                        tailTruncatedCharacterRange = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:location];
                    }
                    
                    // Make sure the tail truncation range is still right after the focused range
                    if (NSMaxRange(focusedRange) != tailTruncatedCharacterRange.location) {
                        _forceTailTruncationRange = true;
                        [self.layoutManager invalidateGlyphsForCharacterRange:(NSRange){ 0, length } changeInLength:0 actualCharacterRange:NULL];
                    }
                }
                
                glyphRange = [self.layoutManager glyphRangeForBoundingRect:bounds inTextContainer:self.textContainer];
            }
            
            [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:rect.origin];
            [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:rect.origin];
        }
    }
}

#pragma mark - Focused Range

- (NSRange)focusedRange
{
    return _selectedRange;
}

- (void)setFocusedRange:(NSRange)focusedRange
{
    _selectedRange = focusedRange;
    [self.textStorage beginEditing];
    [self.textStorage addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:focusedRange];
    [self.textStorage endEditing];
}

#pragma mark - Contents

- (NSAttributedString *)contents
{
    return _textStorage;
}

- (void)setContents:(NSAttributedString *)contents
{
    if (!_textStorage) {
        _layoutManager = [[NSLayoutManager alloc] init];
        _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        _textStorage = [[NSTextStorage alloc] init];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager addTextContainer:_textContainer];
        _layoutManager.delegate = self;
        _textContainer.lineFragmentPadding = 0;
        _textContainer.maximumNumberOfLines = 1;
        _textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    [_textStorage appendAttributedString:contents];
}

#pragma mark - NSLayoutManagerDelegate

- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager
       shouldGenerateGlyphs:(const CGGlyph *)glyphs
                 properties:(const NSGlyphProperty *)props
           characterIndexes:(const NSUInteger *)charIndexes
                       font:(UIFont *)aFont
              forGlyphRange:(NSRange)glyphRange
{
    NSRange range = NSMakeRange(*charIndexes, charIndexes[glyphRange.length - 1] - charIndexes[0] + 1);
    NSRange targetRange = _truncationRange;
    NSRange intersectionRange = NSIntersectionRange(range, targetRange);
    
    if ((intersectionRange.length == 0) && _forceTailTruncationRange) {
        targetRange.location = NSMaxRange(_selectedRange);
        targetRange.length = layoutManager.textStorage.length - targetRange.location;
        intersectionRange = NSIntersectionRange(targetRange, range);
    }
    
    NSInteger BUFFER_LEN = 1; // ??????
    if (intersectionRange.length > 0) {
        CGGlyph glyphBuffer[BUFFER_LEN];
        NSGlyphProperty propBuffer[BUFFER_LEN];
        NSUInteger index;
        
        range = (NSRange){ 0, 0 };
        
        for (index = 0; index < glyphRange.length; index++) {
            if (NSLocationInRange(charIndexes[index], targetRange)) {
                if ((index > 0) && (range.length == 0)) {
                    // flush upto the current index (?)
                    [layoutManager setGlyphs:glyphs properties:props characterIndexes:charIndexes font:aFont forGlyphRange:(NSRange){glyphRange.location, index}];
                }
                if (range.length == BUFFER_LEN) {
                    [layoutManager setGlyphs:glyphBuffer properties:propBuffer characterIndexes:charIndexes + range.location font:aFont forGlyphRange:(NSRange){ glyphRange.location + range.location, range.length }];
                    range.length = 0;
                }
                
                if (range.length == 0) {
                    range.location = index;
                }
                
                if (charIndexes[index] == targetRange.location) {
                    UTF16Char ellipsis = 0x2026;
                    if (CTFontGetGlyphsForCharacters((CTFontRef)aFont, &ellipsis, glyphBuffer + range.length, 1)) {
                        propBuffer[range.length] = 0;
                    } else {
                        // The font doesn't have ellipsis, try rendering manually later
                        glyphBuffer[range.length] = kCGFontIndexInvalid;
                        propBuffer[range.length] = NSGlyphPropertyControlCharacter;
                    }
                } else {
                    glyphBuffer[range.length] = kCGFontIndexInvalid;
                    propBuffer[range.length] = NSGlyphPropertyNull;
                }
                ++range.length;
            } else if (charIndexes[index] >= NSMaxRange(targetRange)) {
                // Past the truncated range
                break;
            }
        }
        
        if (range.length > 0) {
            [layoutManager setGlyphs:glyphBuffer properties:propBuffer characterIndexes:charIndexes + range.location font:aFont forGlyphRange:(NSRange){ glyphRange.location + range.location, range.length }];
        }
        
        if ((glyphRange.length - index) > 0) {
            [layoutManager setGlyphs:glyphs + index properties:props + index characterIndexes:charIndexes + index font:aFont forGlyphRange:(NSRange){ glyphRange.location + index, glyphRange.length - index}];
        }
        return glyphRange.length;
    } else {
        return 0;
    }
}

@end
