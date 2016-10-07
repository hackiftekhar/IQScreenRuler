//
//  ACMagnifyingGlass.h
//  MagnifyingGlass
//

// doc: http://coffeeshopped.com/2010/03/a-simpler-magnifying-glass-loupe-view-for-the-iphone

#import <UIKit/UIKit.h>

extern CGFloat const kACMagnifyingGlassDefaultOffset;

@interface ACMagnifyingGlass : UIView

@property (nonatomic, retain) UIView *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGPoint touchPointOffset;
@property (nonatomic, assign) CGFloat scale; 
@property (nonatomic, assign) BOOL scaleAtTouchPoint; 

@property (nonatomic, strong) UIColor *color;

-(void)show;
-(void)hide;

@end
