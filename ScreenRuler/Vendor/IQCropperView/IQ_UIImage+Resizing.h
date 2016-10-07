//
//  UIImage+Resize.h
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/05/11.
//  Copyright 2012 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import <UIKit/UIImage.h>
#import <UIKit/UIView.h>

typedef enum
{
	IQ_NYXCropModeTopLeft,
	IQ_NYXCropModeTopCenter,
	IQ_NYXCropModeTopRight,
	IQ_NYXCropModeBottomLeft,
	IQ_NYXCropModeBottomCenter,
	IQ_NYXCropModeBottomRight,
	IQ_NYXCropModeLeftCenter,
	IQ_NYXCropModeRightCenter,
	IQ_NYXCropModeCenter
} IQ_NYXCropMode;


@interface UIImage (IQ_NYX_Resizing)

-(UIImage*)IQ_croppedImageInRect:(CGRect)rect;

-(UIImage*)IQ_cropToSize:(CGSize)newSize usingMode:(IQ_NYXCropMode)cropMode;

// NYXCropModeTopLeft crop mode used
-(UIImage*)IQ_cropToSize:(CGSize)newSize;

-(UIImage*)IQ_scaleByFactor:(float)scaleFactor;

// Same as 'scale to fill' in IB.
-(UIImage*)IQ_scaleToFillSize:(CGSize)newSize;

// Preserves aspect ratio. Same as 'aspect fit' in IB.
-(UIImage*)IQ_scaleToFitSize:(CGSize)newSize;

// Preserves aspect ratio. Same as 'aspect fill' in IB.
-(UIImage*)IQ_scaleToCoverSize:(CGSize)newSize;

-(UIImage*)IQ_resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

-(UIImage*)IQ_Thumbnail;

@end
