//
//  ACMagnifyingGlass.m
//  MagnifyingGlass
//

#import "ACMagnifyingGlass.h"
#import <QuartzCore/QuartzCore.h>
#import "IQGeometry+AffineTransform.h"
#import "UIColor+HexColors.h"

CGFloat const kACMagnifyingGlassDefaultOffset = -80;
CGFloat const kACMagnifyingGlassDefaultScale = 3;

@interface ACMagnifyingGlass ()

@property(nonatomic, strong) CALayer *topLayer, *bottomLayer, *leftLayer, *rightLayer;

@end

@implementation ACMagnifyingGlass

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
    {
        {
            UIImageView *loupeImageView = nil;
            loupeImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(CGRectInset(self.bounds, -3.0, -3.0), 0, 2.5)];
            loupeImageView.image = [UIImage imageNamed:@"kb-loupe-hi_7"];
            loupeImageView.backgroundColor = [UIColor clearColor];
            [self addSubview:loupeImageView];
        }

        {
            {
                self.topLayer = [[CALayer alloc] init];
                [self.layer addSublayer:self.topLayer];
            }
            
            {
                self.bottomLayer = [[CALayer alloc] init];
                [self.layer addSublayer:self.bottomLayer];
            }
            
            {
                self.leftLayer = [[CALayer alloc] init];
                [self.layer addSublayer:self.leftLayer];
            }
            
            {
                self.rightLayer = [[CALayer alloc] init];
                [self.layer addSublayer:self.rightLayer];
            }
        }
        
        self.layer.magnificationFilter = kCAFilterNearest;
		self.layer.borderWidth = 1;
        self.layer.opaque = YES;
        self.layer.drawsAsynchronously = YES;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
		self.layer.masksToBounds = YES;
		self.touchPointOffset = CGPointMake(0, kACMagnifyingGlassDefaultOffset);
		self.scale = kACMagnifyingGlassDefaultScale;
		self.viewToMagnify = nil;
		self.scaleAtTouchPoint = YES;
	}
	return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.cornerRadius = self.frame.size.width / 2;
    
    CGFloat width = 1;
    CGFloat height = 5;
    
    self.topLayer.frame     = CGRectMake(CGRectGetMidX(self.bounds)-width/2, CGRectGetMidY(self.bounds)-height-1, width, height);
    self.bottomLayer.frame  = CGRectMake(CGRectGetMidX(self.bounds)-width/2, CGRectGetMidY(self.bounds)+1, width, height);
    self.leftLayer.frame    = CGRectMake(CGRectGetMidX(self.bounds)-height-1, CGRectGetMidY(self.bounds)-width/2, height, width);
    self.rightLayer.frame   = CGRectMake(CGRectGetMidY(self.bounds)+1, CGRectGetMidY(self.bounds)-width/2, height, width);
}

-(void)setColor:(UIColor *)color
{
    _color = color;

    if ([color isDarkColor])
    {
        self.topLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.bottomLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.leftLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        self.rightLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    else
    {
        self.topLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.bottomLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.leftLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.rightLayer.backgroundColor = [[UIColor blackColor] CGColor];
    }
}

- (void)setTouchPoint:(CGPoint)point
{
	_touchPoint = point;
    
    {
        CGPoint originalPoint = [self.viewToMagnify convertPoint:point toView:self.superview];
        CGPoint superTouchPoint = originalPoint;
        superTouchPoint.x = MAX(superTouchPoint.x, CGRectGetMidX(self.bounds));
        superTouchPoint.x = MIN(superTouchPoint.x, CGRectGetWidth(self.superview.bounds)-CGRectGetMidX(self.bounds));
        
        if (originalPoint.y < -self.touchPointOffset.y*2)
        {
            CGFloat diff = -self.touchPointOffset.y*2 - superTouchPoint.y;
            diff = MIN(diff, CGRectGetMidX(self.bounds));
            superTouchPoint.y = -self.touchPointOffset.y*2;
            
            if (originalPoint.x < CGRectGetMidX(self.superview.bounds))
            {
                superTouchPoint.x += MIN(diff,originalPoint.x);
            }
            else
            {
                superTouchPoint.x -= MIN(diff,CGRectGetWidth(self.superview.bounds)-originalPoint.x);
            }
        }

        self.center = CGPointMake(superTouchPoint.x + self.touchPointOffset.x, superTouchPoint.y + self.touchPointOffset.y);
    }

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2);
    
    CGSize viewToMagnifyScale = IQAffineTransformGetScale(self.viewToMagnify.superview.transform);

	CGContextScaleCTM(context, self.scale*viewToMagnifyScale.width, self.scale*viewToMagnifyScale.height);
	CGContextTranslateCTM(context, -self.touchPoint.x, -self.touchPoint.y + (self.scaleAtTouchPoint? 0 : self.bounds.size.height/2));

    [self.viewToMagnify.layer renderInContext:context];
}

-(void)show
{
    self.touchPoint = self.touchPoint;  // To update touch view center
    
    self.transform = CGAffineTransformMake(0.1, 0, 0, 0.1, 0, 60);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

-(void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMake(0.1, 0, 0, 0.1, 0, 60);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
