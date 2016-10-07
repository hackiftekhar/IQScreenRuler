//
//  IQCropperView.h
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>

@class IQCropperView;

typedef NS_ENUM(NSInteger, IQCropViewEdge) {
    IQCropViewEdgeNone,
    IQCropViewEdgeTopLeft,
    IQCropViewEdgeTop,
    IQCropViewEdgeTopRight,
    IQCropViewEdgeRight,
    IQCropViewEdgeBottomRight,
    IQCropViewEdgeBottom,
    IQCropViewEdgeBottomLeft,
    IQCropViewEdgeLeft
};

typedef NS_ENUM(NSInteger, IQ_IQAspectSize) {
    IQ_IQAspectSizeOriginal,
    IQ_IQAspectSizeSquare,
    
    IQ_IQAspectSize2x3,
    IQ_IQAspectSize3x4,
    IQ_IQAspectSize4x5,
    IQ_IQAspectSize5x7,
    IQ_IQAspectSize9x16,
    IQ_IQAspectSize1x235,
    
    IQ_IQAspectSize3x2,
    IQ_IQAspectSize4x3,
    IQ_IQAspectSize5x4,
    IQ_IQAspectSize7x5,
    IQ_IQAspectSize16x9,
    IQ_IQAspectSize235x1,

};

@protocol IQCropViewDelegate <NSObject>

@optional
-(void)cropViewDidChangedCropRect:(IQCropperView*)view;

@end

@interface IQCropperView : UIView

@property(nonatomic, assign) UIEdgeInsets edgeInset;

@property(nonatomic, weak) IBOutlet id<IQCropViewDelegate> delegate;
@property(nonatomic, assign) CGRect cropRect;
@property(nonatomic, assign) IQ_IQAspectSize aspectSize;

-(void)updateCropRectAnimated:(BOOL)animated;

@end
