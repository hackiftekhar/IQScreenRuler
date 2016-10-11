//
//  UIImage+Color.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "UIImage+Color.h"

#import <objc/runtime.h>

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    if (color)
    {
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContextWithOptions(rect.size, CGColorGetAlpha(color.CGColor) == 1.0?YES:NO, [[UIScreen mainScreen] scale]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    else
    {
        return nil;
    }
}

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);

    BOOL hasAlpha = (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);

    UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

static char kPixelData;

-(void)dealloc
{
    CFDataRef pixelData = (__bridge CFDataRef)(objc_getAssociatedObject(self, &kPixelData));

    if (pixelData)
    {
        CFRelease(pixelData);
    }
}

-(void)colorAtPoint:(CGPoint)point preparingBlock:(void (^)(void))preparingBlock completion:(void (^)(UIColor*))colorCompletion
{
    if (point.x <= 0 || point.y <= 0 || point.x > self.size.width || point.y > self.size.height)
    {
        if (colorCompletion)
        {
            colorCompletion(nil);
        }
    }
    //Method1 but having a huge performance hit with CGDataProviderCopyData method
    else
    {
        __weak typeof(self) weakSelf = self;

        void(^getColorBlock)(const UInt8* data) = ^(const UInt8* data){
            
            int numberOfColorComponents = 4; // R,G,B, and A
            NSInteger pointX = ceilf(point.x)-1;
            NSInteger pointY = ceilf(point.y)-1;
            
            float w = weakSelf.size.width;
            int pixelInfo = ((w * pointY) + pointX) * numberOfColorComponents;
            
            int red = 0;
            int green = 0;
            int blue = 0;
            int alpha = 255;
            
            switch (CGImageGetAlphaInfo(weakSelf.CGImage))
            {
                case kCGImageAlphaNone:
                case kCGImageAlphaNoneSkipLast:
                    red     = data[pixelInfo + 0];
                    green   = data[pixelInfo + 1];
                    blue    = data[pixelInfo + 2];
                    break;
                case kCGImageAlphaPremultipliedLast:
                case kCGImageAlphaLast:
                    red     = data[pixelInfo + 0];
                    green   = data[pixelInfo + 1];
                    blue    = data[pixelInfo + 2];
                    alpha   = data[pixelInfo + 3];
                    break;
                case kCGImageAlphaPremultipliedFirst:
                case kCGImageAlphaFirst:
                    alpha   = data[pixelInfo + 0];
                case kCGImageAlphaNoneSkipFirst:
                    red     = data[pixelInfo + 1];
                    green   = data[pixelInfo + 2];
                    blue    = data[pixelInfo + 3];
                    break;
                case kCGImageAlphaOnly:
                    alpha   = data[pixelInfo + 0];
                    break;
                    
                default:
                    break;
            }
            
            // RGBA values range from 0 to 255
            UIColor *color = [UIColor colorWithRed:red/255.0
                                   green:green/255.0
                                    blue:blue/255.0
                                   alpha:alpha/255.0];
            
            if (colorCompletion)
            {
                colorCompletion(color);
            }
        };
        
        CFDataRef pixelData = (__bridge CFDataRef)(objc_getAssociatedObject(self, &kPixelData));

        if (pixelData)
        {
            getColorBlock(CFDataGetBytePtr(pixelData));
        }
        else
        {
            if (preparingBlock)
            {
                preparingBlock();
            }
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.qualityOfService = NSQualityOfServiceUserInteractive;
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                CGDataProviderRef provider = CGImageGetDataProvider(weakSelf.CGImage);
                CFDataRef pixelData = CGDataProviderCopyData(provider);
                
                objc_setAssociatedObject(weakSelf, &kPixelData, (__bridge NSData*)(pixelData), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    getColorBlock(CFDataGetBytePtr(pixelData));
                }];
            }];
            
            operation.qualityOfService = NSQualityOfServiceUserInteractive;
            [queue addOperation:operation];
        }
    }
}

@end
