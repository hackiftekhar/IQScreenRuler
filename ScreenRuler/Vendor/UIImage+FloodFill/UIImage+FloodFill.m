//
//  UIImage+FloodFill.m
//  ImageFloodFilleDemo
//
//  Created by chintan on 15/07/13.
//  Copyright (c) 2013 ZWT. All rights reserved.
//

#import "UIImage+FloodFill.h"

#define DEBUG_ANTIALIASING 0

@implementation UIImage (FloodFill)
/*
    startPoint : Point from where you want to color. Generaly this is touch point.
                 This is important because color at start point will be replaced with other.
    
    newColor   : This color will be apply at point where the match on startPoint color found.
 
    tolerance  : If Tolerance is 0 than it will search for exact match of color 
                 other wise it will take range according to tolerance value.
            
                 If You dont want to use tolerance and want to incress performance Than you can change
                 compareColor(ocolor, color, tolerance) with just ocolor==color which reduse function call.
*/
- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance
{
    return [self floodFillFromPoint:startPoint withColor:newColor andTolerance:tolerance useAntiAlias:YES];
}

- (UIImage *) floodFillFromPoint:(CGPoint)startPoint withColor:(UIColor *)newColor andTolerance:(int)tolerance useAntiAlias:(BOOL)antiAlias
{
    @try
    {
        /*
            First We create rowData from UIImage.
            We require this conversation so that we can use detail at pixel like color at pixel.
            You can get some discussion about this topic here:
            http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
        */
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGImageRef imageRef = [self CGImage];
        
        NSInteger width = CGImageGetWidth(imageRef);
        NSInteger height = CGImageGetHeight(imageRef);
        
        unsigned char *imageData = malloc(height * width * 4);
        
        NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
        NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);
        NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        if (kCGImageAlphaLast == (uint32_t)bitmapInfo || kCGImageAlphaFirst == (uint32_t)bitmapInfo) {
            bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
        }
        
        CGContextRef context = CGBitmapContextCreate(imageData,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        
        //Get color at start point 
		unsigned int byteIndex = (bytesPerRow * roundf(startPoint.y)) + roundf(startPoint.x) * bytesPerPixel;
        
        unsigned int ocolor = getColorCode(byteIndex, imageData);
        
        if (compareColor(ocolor, 0, 0)) {
            return nil;
        }
        
        //Convert newColor to RGBA value so we can save it to image.
        int newRed, newGreen, newBlue, newAlpha;
        
        const CGFloat *components = CGColorGetComponents(newColor.CGColor);
        
        /*
            If you are not getting why I use CGColorGetNumberOfComponents than read following link:
            http://stackoverflow.com/questions/9238743/is-there-an-issue-with-cgcolorgetcomponents
        */
        
        if(CGColorGetNumberOfComponents(newColor.CGColor) == 2)
        {
            newRed   = newGreen = newBlue = components[0] * 255;
            newAlpha = components[1] * 255;
        }
        else if (CGColorGetNumberOfComponents(newColor.CGColor) == 4)
        {
            if ((bitmapInfo&kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little)
            {
                newRed   = components[2] * 255;
                newGreen = components[1] * 255;
                newBlue  = components[0] * 255;
                newAlpha = 255;
            }
            else
            {
                newRed   = components[0] * 255;
                newGreen = components[1] * 255;
                newBlue  = components[2] * 255;
                newAlpha = 255;
            }
        }
        
        unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
        
        /*
            We are using stack to store point.
            Stack is implemented by LinkList.
            To incress speed I have used NSMutableData insted of NSMutableArray.
            To see Detail Of This implementation visit following leink.
            http://iwantmyreal.name/blog/2012/09/29/a-faster-array-in-objective-c/
        */
        
        LinkedListStack *points = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:500 andMultiplier:height];
        LinkedListStack *antiAliasingPoints = [[LinkedListStack alloc] initWithCapacity:500 incrementSize:500 andMultiplier:height];
        
        NSInteger x = roundf(startPoint.x);
        NSInteger y = roundf(startPoint.y);
        
        [points pushFrontX:x andY:y];
        
        /*
            This algorithem is prety simple though it llook odd in Objective C syntex.
            To get familer with this algorithm visit following link.
            http://lodev.org/cgtutor/floodfill.html
            You can read hole artical for knowledge. 
            If you are familer with flood fill than got to Scanline Floodfill Algorithm With Stack (floodFillScanlineStack)
        */
        
        unsigned int color;
        BOOL spanLeft,spanRight;
        
        while ([points popFront:&x andY:&y] != INVALID_NODE_CONTENT)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
            
            color = getColorCode(byteIndex, imageData);
            
            while(y >= 0 && compareColor(ocolor, color, tolerance))
            {
                y--;
                
                if(y >= 0)
                {
                    byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                
                    color = getColorCode(byteIndex, imageData);
                }
            }
            
            // Add the top most point on the antialiasing list
            if(y >= 0 && !compareColor(ocolor, color, 0))
            {
                [antiAliasingPoints pushFrontX:x andY:y];
            }
            
            y++;
            
            spanLeft = spanRight = NO;
            
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
            
            color = getColorCode(byteIndex, imageData);
            
            while (y < height && compareColor(ocolor, color, tolerance) && ncolor != color)
            {
                //Change old color with newColor RGBA value
                imageData[byteIndex + 0] = newRed;
                imageData[byteIndex + 1] = newGreen;
                imageData[byteIndex + 2] = newBlue;
                imageData[byteIndex + 3] = newAlpha;
                
                if(x > 0)
                {
                    byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
                    
                    color = getColorCode(byteIndex, imageData);
                    
                    if(!spanLeft && x > 0 && compareColor(ocolor, color, tolerance))
                    {
                        [points pushFrontX:(x - 1) andY:y];
                    
                        spanLeft = YES;
                    }
                    else if(spanLeft && x > 0 && !compareColor(ocolor, color, tolerance))
                    {
                        spanLeft = NO;
                    }
                    
                    // we can't go left. Add the point on the antialiasing list
                    if(!spanLeft && x > 0 && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance))
                    {
                        [antiAliasingPoints pushFrontX:(x - 1) andY:y];
                    }
                }
                
                if(x < width - 1)
                {
                    byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;;
                    
                    color = getColorCode(byteIndex, imageData);
                    
                    if(!spanRight && compareColor(ocolor, color, tolerance))
                    {
                        [points pushFrontX:(x + 1) andY:y];
                        
                        spanRight = YES;
                    }
                    else if(spanRight && !compareColor(ocolor, color, tolerance))
                    {
                        spanRight = NO;
                    }
                    
                    // we can't go right. Add the point on the antialiasing list
                    if(!spanRight && !compareColor(ocolor, color, tolerance) && !compareColor(ncolor, color, tolerance))
                    {
                        [antiAliasingPoints pushFrontX:(x + 1) andY:y];
                    }
                }
                
                y++;
                
                if(y < height)
                {
                    byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                
                    color = getColorCode(byteIndex, imageData);
                }
            }
            
            if (y<height)
            {
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                
                // Add the bottom point on the antialiasing list
                if (!compareColor(ocolor, color, 0))
                    [antiAliasingPoints pushFrontX:x andY:y];
            }
        }
        
        // For each point marked
        // perform antialiasing on the same pixel, plus the top,left,bottom and right pixel
        unsigned int antialiasColor = getColorCodeFromUIColor(newColor,bitmapInfo&kCGBitmapByteOrderMask );
        int red1   = ((0xff000000 & antialiasColor) >> 24);
        int green1 = ((0x00ff0000 & antialiasColor) >> 16);
        int blue1  = ((0x0000ff00 & antialiasColor) >> 8);
        int alpha1 =  (0x000000ff & antialiasColor);

        while ([antiAliasingPoints popFront:&x andY:&y] != INVALID_NODE_CONTENT)
        {
            byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
            color = getColorCode(byteIndex, imageData);

            if (!compareColor(ncolor, color, 0))
            {
                int red2   = ((0xff000000 & color) >> 24);
                int green2 = ((0x00ff0000 & color) >> 16);
                int blue2 = ((0x0000ff00 & color) >> 8);
                int alpha2 =  (0x000000ff & color);

                if (antiAlias) {
                    imageData[byteIndex + 0] = (red1 + red2) / 2;
                    imageData[byteIndex + 1] = (green1 + green2) / 2;
                    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                } else {
                    imageData[byteIndex + 0] = red2;
                    imageData[byteIndex + 1] = green2;
                    imageData[byteIndex + 2] = blue2;
                    imageData[byteIndex + 3] = alpha2;
                }
                
#if DEBUG_ANTIALIASING
                imageData[byteIndex + 0] = 0;
                imageData[byteIndex + 1] = 0;
                imageData[byteIndex + 2] = 255;
                imageData[byteIndex + 3] = 255;
#endif
            }
            
            // left
            if (x>0)
            {
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x - 1) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                
                if (!compareColor(ncolor, color, 0))
                {
                    int red2   = ((0xff000000 & color) >> 24);
                    int green2 = ((0x00ff0000 & color) >> 16);
                    int blue2 = ((0x0000ff00 & color) >> 8);
                    int alpha2 =  (0x000000ff & color);
                    
                    if (antiAlias) {
                        imageData[byteIndex + 0] = (red1 + red2) / 2;
                        imageData[byteIndex + 1] = (green1 + green2) / 2;
                        imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                        imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                    } else {
                        imageData[byteIndex + 0] = red2;
                        imageData[byteIndex + 1] = green2;
                        imageData[byteIndex + 2] = blue2;
                        imageData[byteIndex + 3] = alpha2;
                    }
                    
#if DEBUG_ANTIALIASING
                    imageData[byteIndex + 0] = 0;
                    imageData[byteIndex + 1] = 0;
                    imageData[byteIndex + 2] = 255;
                    imageData[byteIndex + 3] = 255;
#endif
                }
            }
            if (x<width)
            {
                byteIndex = (bytesPerRow * roundf(y)) + roundf(x + 1) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                
                if (!compareColor(ncolor, color, 0))
                {
                    int red2   = ((0xff000000 & color) >> 24);
                    int green2 = ((0x00ff0000 & color) >> 16);
                    int blue2 = ((0x0000ff00 & color) >> 8);
                    int alpha2 =  (0x000000ff & color);
                    
                    if (antiAlias) {
                        imageData[byteIndex + 0] = (red1 + red2) / 2;
                        imageData[byteIndex + 1] = (green1 + green2) / 2;
                        imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                        imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                    } else {
                        imageData[byteIndex + 0] = red2;
                        imageData[byteIndex + 1] = green2;
                        imageData[byteIndex + 2] = blue2;
                        imageData[byteIndex + 3] = alpha2;
                    }

#if DEBUG_ANTIALIASING
                    imageData[byteIndex + 0] = 0;
                    imageData[byteIndex + 1] = 0;
                    imageData[byteIndex + 2] = 255;
                    imageData[byteIndex + 3] = 255;
#endif
                }

            }
            
            if (y>0)
            {
                byteIndex = (bytesPerRow * roundf(y - 1)) + roundf(x) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                
                if (!compareColor(ncolor, color, 0))
                {
                    int red2   = ((0xff000000 & color) >> 24);
                    int green2 = ((0x00ff0000 & color) >> 16);
                    int blue2 = ((0x0000ff00 & color) >> 8);
                    int alpha2 =  (0x000000ff & color);
                    
                    if (antiAlias) {
                        imageData[byteIndex + 0] = (red1 + red2) / 2;
                        imageData[byteIndex + 1] = (green1 + green2) / 2;
                        imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                        imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                    } else {
                        imageData[byteIndex + 0] = red2;
                        imageData[byteIndex + 1] = green2;
                        imageData[byteIndex + 2] = blue2;
                        imageData[byteIndex + 3] = alpha2;
                    }
                    
#if DEBUG_ANTIALIASING
                    imageData[byteIndex + 0] = 0;
                    imageData[byteIndex + 1] = 0;
                    imageData[byteIndex + 2] = 255;
                    imageData[byteIndex + 3] = 255;
#endif
                }
            }
            
            if (y<height)
            {
                byteIndex = (bytesPerRow * roundf(y + 1)) + roundf(x) * bytesPerPixel;
                color = getColorCode(byteIndex, imageData);
                
                if (!compareColor(ncolor, color, 0))
                {
                    int red2   = ((0xff000000 & color) >> 24);
                    int green2 = ((0x00ff0000 & color) >> 16);
                    int blue2 = ((0x0000ff00 & color) >> 8);
                    int alpha2 =  (0x000000ff & color);
                    
                    if (antiAlias) {
                        imageData[byteIndex + 0] = (red1 + red2) / 2;
                        imageData[byteIndex + 1] = (green1 + green2) / 2;
                        imageData[byteIndex + 2] = (blue1 + blue2) / 2;
                        imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
                    } else {
                        imageData[byteIndex + 0] = red2;
                        imageData[byteIndex + 1] = green2;
                        imageData[byteIndex + 2] = blue2;
                        imageData[byteIndex + 3] = alpha2;
                    }
                    
#if DEBUG_ANTIALIASING
                    imageData[byteIndex + 0] = 0;
                    imageData[byteIndex + 1] = 0;
                    imageData[byteIndex + 2] = 255;
                    imageData[byteIndex + 3] = 255;
#endif
                }

            }
        }
        
        //Convert Flood filled image row data back to UIImage object.
        
        CGImageRef newCGImage = CGBitmapContextCreateImage(context);
        
        UIImage *result = [UIImage imageWithCGImage:newCGImage scale:[self scale] orientation:UIImageOrientationUp];
        
        CGImageRelease(newCGImage);
        
        CGContextRelease(context);
    
        free(imageData);
        
        return result;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception : %@", exception);
    }
}

/*
    I have used pure C function because it is said than C function is faster than Objective - C method in call.
    This two function are called most of time so it require that calling this work in speed.
    I have not verified this performance so I like to here comment on this.
*/
/*
    This function extract color from image and convert it to integer represent.
 
    Converting to integer make comperation easy.
*/
unsigned int getColorCode (unsigned int byteIndex, unsigned char *imageData)
{
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}

/*
    This function compare two color with counting tolerance value.
 
    If color is between tolerance rancge than it return true other wise false.
*/
bool compareColor (unsigned int color1, unsigned int color2, int tolorance)
{
    if(color1 == color2)
        return true;
    
    int red1   = ((0xff000000 & color1) >> 24);
    int green1 = ((0x00ff0000 & color1) >> 16);
    int blue1  = ((0x0000ff00 & color1) >> 8);
    int alpha1 =  (0x000000ff & color1);
    
    int red2   = ((0xff000000 & color2) >> 24);
    int green2 = ((0x00ff0000 & color2) >> 16);
    int blue2  = ((0x0000ff00 & color2) >> 8);
    int alpha2 =  (0x000000ff & color2);
    
    int diffRed   = abs(red2   - red1);
    int diffGreen = abs(green2 - green1);
    int diffBlue  = abs(blue2  - blue1);
    int diffAlpha = abs(alpha2 - alpha1);
    
    if( diffRed   > tolorance ||
        diffGreen > tolorance ||
        diffBlue  > tolorance ||
        diffAlpha > tolorance  )
    {
        return false;
    }
    
    return true;
}

unsigned int getColorCodeFromUIColor(UIColor *color, CGBitmapInfo orderMask)
{
    //Convert newColor to RGBA value so we can save it to image.
    int newRed, newGreen, newBlue, newAlpha;
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    /*
     If you are not getting why I use CGColorGetNumberOfComponents than read following link:
     http://stackoverflow.com/questions/9238743/is-there-an-issue-with-cgcolorgetcomponents
     */
    
    if(CGColorGetNumberOfComponents(color.CGColor) == 2)
    {
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }
    else if (CGColorGetNumberOfComponents(color.CGColor) == 4)
    {
        if (orderMask == kCGBitmapByteOrder32Little)
        {
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }
        else
        {
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    else
    {
        newRed   = newGreen = newBlue = 0;
        newAlpha = 255;
    }
    
    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;

    return ncolor;
}

@end
