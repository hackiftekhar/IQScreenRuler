//
//  UIImage+Resize.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "IQ_UIImage+Resizing.h"

//#import "IQ_NYXImagesHelper.h"

#import <UIKit/UIGraphics.h>

@implementation UIImage (IQ_NYX_Resizing)

- (UIImage *)IQ_croppedImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

-(UIImage*)IQ_cropToSize:(CGSize)newSize usingMode:(IQ_NYXCropMode)cropMode
{
	const CGSize size = self.size;
	CGFloat x, y;
	switch (cropMode)
	{
		case IQ_NYXCropModeTopLeft:
			x = y = 0.0f;
			break;
		case IQ_NYXCropModeTopCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = 0.0f;
			break;
		case IQ_NYXCropModeTopRight:
			x = size.width - newSize.width;
			y = 0.0f;
			break;
		case IQ_NYXCropModeBottomLeft:
			x = 0.0f;
			y = size.height - newSize.height;
			break;
		case IQ_NYXCropModeBottomCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = size.height - newSize.height;
			break;
		case IQ_NYXCropModeBottomRight:
			x = size.width - newSize.width;
			y = size.height - newSize.height;
			break;
		case IQ_NYXCropModeLeftCenter:
			x = 0.0f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case IQ_NYXCropModeRightCenter:
			x = size.width - newSize.width;
			y = (size.height - newSize.height) * 0.5f;
			break;
		case IQ_NYXCropModeCenter:
			x = (size.width - newSize.width) * 0.5f;
			y = (size.height - newSize.height) * 0.5f;
			break;
		default: // Default to top left
			x = y = 0.0f;
			break;
	}

	CGRect cropRect = CGRectMake(x * self.scale, y * self.scale, newSize.width * self.scale, newSize.height * self.scale);

	/// Create the cropped image
	CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
	UIImage* cropped = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];

	/// Cleanup
	CGImageRelease(croppedImageRef);

	return cropped;
}

/* Convenience method to crop the image from the top left corner */
-(UIImage*)IQ_cropToSize:(CGSize)newSize
{
	return [self IQ_cropToSize:newSize usingMode:IQ_NYXCropModeTopLeft];
}

-(UIImage*)IQ_scaleByFactor:(float)scaleFactor
{
	CGSize scaledSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
	return [self IQ_scaleToFillSize:scaledSize];
}

-(UIImage*)IQ_scaleToFillSize:(CGSize)newSize
{
	size_t destWidth = (size_t)(newSize.width * self.scale);
	size_t destHeight = (size_t)(newSize.height * self.scale);
	if (self.imageOrientation == UIImageOrientationLeft
		|| self.imageOrientation == UIImageOrientationLeftMirrored
		|| self.imageOrientation == UIImageOrientationRight
		|| self.imageOrientation == UIImageOrientationRightMirrored)
	{
		size_t temp = destWidth;
		destWidth = destHeight;
		destHeight = temp;
	}

  /// Create an ARGB bitmap context
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    BOOL hasAlpha = (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
    
    CGImageAlphaInfo alphaInfo = (hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL, destWidth, destHeight, 8/*Bits per component*/, destWidth * 4, colorSpaceRef, kCGBitmapByteOrderDefault | alphaInfo);

    CGColorSpaceRelease(colorSpaceRef);
    
    if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Draw the image in the bitmap context

	UIGraphicsPushContext(bmContext);
  CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, destWidth, destHeight), self.CGImage);
	UIGraphicsPopContext();

	/// Create an image object from the context
	CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef scale:self.scale orientation:self.imageOrientation];

	/// Cleanup
	CGImageRelease(scaledImageRef);
	CGContextRelease(bmContext);

	return scaled;
}

-(UIImage*)IQ_scaleToFitSize:(CGSize)newSize
{
	/// Keep aspect ratio
	size_t destWidth, destHeight;
	if (self.size.width > self.size.height)
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
	}
	else
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
	}
	if (destWidth > newSize.width)
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
	}
	if (destHeight > newSize.height)
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
	}
	return [self IQ_scaleToFillSize:CGSizeMake(destWidth, destHeight)];
}

-(UIImage*)IQ_scaleToCoverSize:(CGSize)newSize
{
	size_t destWidth, destHeight;
	CGFloat widthRatio = newSize.width / self.size.width;
	CGFloat heightRatio = newSize.height / self.size.height;
	/// Keep aspect ratio
	if (heightRatio > widthRatio)
	{
		destHeight = (size_t)newSize.height;
		destWidth = (size_t)(self.size.width * newSize.height / self.size.height);
	}
	else
	{
		destWidth = (size_t)newSize.width;
		destHeight = (size_t)(self.size.height * newSize.width / self.size.width);
	}
	return [self IQ_scaleToFillSize:CGSizeMake(destWidth, destHeight)];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)IQ_resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", (long)contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}


// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        default:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        default:
            break;
    }
    
    return transform;
}

-(UIImage *)IQ_Thumbnail
{
    return [self IQ_scaleToFitSize:CGSizeMake(50, 50)];
}

@end
