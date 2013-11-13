# Multiple Truncation Example

This is an attempt to replicate the demo code shown in WWDC 2013 session [#220 Advanced Text Layouts and Effects with Text Kit](https://developer.apple.com/wwdc/videos/index.php?id=220). I did this because the example of glyph substitution code that is shown in that talk was never published as sample code as far as I can tell. Which is really disappointing because there are a lot of interesting things that can be done with Glyph substitution in text kit, but it is kind of a tricky API and sample code is super helpful to understand how it is supposed to work.

The purpose of the sample as presented in the talk is to demonstrate glyph substitution in the NSLayoutManagerDelegate to ensure that a highlighted range of text in a string is not truncated by a tail truncation. This is performed by detecting when part of the highlighted text would be truncated, adding a second truncation in the middle of the string by replacing some glyphs with an ellipsis.

![Screencast of truncation effect](http://f.cl.ly/items/3V2L072w3Q0v401e3Q03/Untitled.gif)

# Notes

The code was partially transcribed from the talk, but then I had to make several alterations:

## I'm forcing invalidation of layout manager's layout in the drawRect

Initially when I got it running there was a bug where once you had shrunk the text view and truncated the text to the point where it triggered the middle truncation it would never stop truncating in the middle if you grew the width of the text view again. This is because when the text view attempts to render the text again at the larger size the glyph substitution that has been performed doesn't ever get invalidated and so it will continue to think that it needs to be tail truncated at the same place as well. I force it to invalidate the layout at the beginning of the drawRect method.

It's interesting that they never show the text view expanding again in the demo, it may be that this is just a bug in that code that they were very careful to not show. Or maybe they just picked a different spot to invalidate that layout in some of the code that wasn't ever shown on the video

## Switch from glyph ranges to character ranges
2 Additionally I found that the truncation didn't work as intended because when the tail truncation intersected our focused range, glyphRangeForCharacterRange:actualCharacterRange: would return the glyph range representing the focused range AND all the glyphs that were being replaced by the ellipsis. This meant that the conditional in the while loop checking whether the tail truncated range intersected with the focused range would always return true and the text would truncate to the beginning of the string. To avoid this I translate the glyph range returned from truncatedGlyphRangeInLineFragmentForGlyphAtIndex: into a character range to compare directly with focused range

## Switched from lorem ipsum to [hipster ipsum](http://hipsteripsum.me)

## Some DRYing/Cleaning up of code