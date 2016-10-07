//
//  SmoothedBIView.m
//  FreehandDrawingTut
//
//  Created by A Khan on 12/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IQ_SmoothedBIView.h"

@implementation IQ_SmoothedBIView
{
    NSMutableArray *bezierPaths;
    NSMutableArray *strokeColors;
    
    UIBezierPath *path;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

@synthesize strokeColor = _strokeColor;
@synthesize strokeWidth = _strokeWidth;

-(void)initialize
{
    self.layer.magnificationFilter = kCAFilterNearest;

    [self setBackgroundColor:[UIColor clearColor]];

    _strokeColor = [UIColor blackColor];
    _strokeWidth = 5.0;
    
    bezierPaths = [[NSMutableArray alloc] init];
    strokeColors = [[NSMutableArray alloc] init];
    
    [self setStrokeColor:[UIColor blackColor]];
    [self setStrokeWidth:10.0];
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    _panRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panRecognizer];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(void)setStrokeWidth:(CGFloat)strokeWidth
{
    _strokeWidth = strokeWidth;
    [path setLineWidth:strokeWidth];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Fill previously draw path.
    for (NSInteger i = 0; i<bezierPaths.count; i++)
    {
        [[strokeColors objectAtIndex:i] setStroke];
        [[bezierPaths objectAtIndex:i] stroke];
    }
    
    //Fill current Path
    if (ctr != 0)
    {
        [_strokeColor setStroke];
        [path stroke];
    }
}

-(void)panRecognized:(UIPanGestureRecognizer*)gesture
{
    CGPoint touchPoint = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        path = [UIBezierPath bezierPath];
        [path setLineWidth:_strokeWidth];
        [path setLineCapStyle:kCGLineCapRound];
        
        ctr = 0;
        pts[0] = touchPoint;

        [self setNeedsDisplay];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        ctr++;
        pts[ctr] = touchPoint;
        if (ctr == 4)
        {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            [path moveToPoint:pts[0]];
            [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
            
            [self setNeedsDisplay];
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4]; 
            ctr = 1;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (ctr != 0)
        {
            [bezierPaths addObject:path];
            [strokeColors addObject:_strokeColor];
        }
        path = nil;

        [self setNeedsDisplay];

        ctr = 0;
    }
}

-(void)clear
{
    [bezierPaths removeAllObjects];
    [strokeColors removeAllObjects];
    path = nil;
    
    [self setNeedsDisplay];
}

-(void)dealloc
{
    [bezierPaths removeAllObjects];
    [strokeColors removeAllObjects];
    path = nil;
}

@end



