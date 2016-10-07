//
//  IQColorPickerButton.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQColorPickerButton.h"
#import "HFColorPickerView.h"
#import "UIColor+HexColors.h"

@interface IQColorPickerButton ()<HFColorPickerViewDelegate>

@end


@implementation IQColorPickerButton
{
    HFColorPickerView *colorPickerView;
}

-(void)initialize
{
    self.selected = YES;
    
    colorPickerView = [[HFColorPickerView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 180)];
    colorPickerView.layer.shadowColor = [UIColor blackColor].CGColor;
    colorPickerView.layer.shadowOffset = CGSizeMake(0, 1);
    colorPickerView.layer.shadowRadius = 2;
    colorPickerView.layer.shadowOpacity = 0.3;
    colorPickerView.backgroundColor = [UIColor clearColor];
    colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    colorPickerView.delegate = self;
    colorPickerView.colors = [[HFColorPickerView colorAttributes] valueForKey:@"color"];
    self.inputView = colorPickerView;

    {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        [toolbar sizeToFit];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        //Flexible space
        UIBarButtonItem *nilButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObject:nilButton];
        
        //Done button
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        [items addObject:doneButton];
        
        //  Adding button to toolBar.
        [toolbar setItems:items];
        
        self.inputAccessoryView = toolbar;
        
        [self addTarget:self action:@selector(colorPickerTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    self.tintColor = [UIColor clearColor];
    
    self.color = [colorPickerView.colors firstObject];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

-(void)doneAction:(UIBarButtonItem*)item
{
    [self resignFirstResponder];
}

-(void)colorPickerTapped:(IQColorPickerButton*)ColorPickerButton
{
    [self becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
//    BOOL canBecomeFirstResponder = [super canBecomeFirstResponder];
    
    return YES;
}

-(void)setColor:(UIColor *)color
{
    NSArray *colorArray = [HFColorPickerView colorAttributes];
    for (int i =0; i<[colorArray count]; i++)
    {
        NSDictionary *colorAttributes = [colorArray objectAtIndex:i];
        
        UIColor *attributeColor = [colorAttributes objectForKey:@"color"];
        
        if ([[attributeColor hexValue] isEqualToString:[color hexValue]])
        {
            [super setColor:color];
            colorPickerView.selectedIndex = i;
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            break;
        }
    }
}

- (void)colorPicker:(HFColorPickerView*)colorPickerView selectedColor:(UIColor*)selectedColor
{
    self.color = selectedColor;
}
@end
