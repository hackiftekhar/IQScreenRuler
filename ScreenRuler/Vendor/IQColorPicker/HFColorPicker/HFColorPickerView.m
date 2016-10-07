//
//  HFColorPickerView.m
//  HFColorPickerDemo
//
//  Created by Hendrik Frahmann on 30.04.14.
//  Copyright (c) 2014 Hendrik Frahmann. All rights reserved.
//

#import "HFColorPickerView.h"
#import "HFColorButton.h"

@interface HFColorPickerView()

@property (nonatomic, strong) NSMutableArray* colorButtons;

- (void)setupColorButtons;
- (void)buttonClicked:(id)sender;
- (void)selectButton:(HFColorButton*)button;
- (void)calculateButtonFrames;

@end


@implementation HFColorPickerView

@synthesize colorButtons   = _colorButtons;
@synthesize colors         = _colors;
@synthesize buttonDiameter = _buttonDiameter;
@synthesize selectedIndex  = _selectedIndex;
@synthesize numberOfColorsPerRow       = _numberOfColorsPerRow;

+(NSArray *)colorAttributes
{
    return @[@{@"name":@"Black",
               @"color":[UIColor colorWithRed:0 green:0 blue:0 alpha:1]},
             
             @{@"name":@"Dark Gray",
               @"color":[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]},
             
             @{@"name":@"Gray",
               @"color":[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]},
             
             @{@"name":@"Light Gray",
               @"color":[UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1]},
             
             @{@"name":@"White",
               @"color":[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]},
             
             
             
             @{@"name":@"Brown",
               @"color":[UIColor colorWithRed:121.0/255.0f green:85.0/255.0f blue:72.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Red",
               @"color":[UIColor colorWithRed:244.0/255.0f green:67.0/255.0f blue:54.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Deep Orange",
               @"color":[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1.0]},
             
             @{@"name":@"Orange",
               @"color":[UIColor colorWithRed:255.0/255.0 green:152.0/255.0 blue:0.0/255.0 alpha:1.0]},
             
             @{@"name":@"Amber",
               @"color":[UIColor colorWithRed:255.0/255.0 green:193.0/255.0 blue:7.0/255.0 alpha:1.0]},
             
             
             
             @{@"name":@"Teal",
               @"color":[UIColor colorWithRed:0.0/255.0f green:150.0/255.0f blue:136.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Green",
               @"color":[UIColor colorWithRed:76.0/255.0f green:175.0/255.0f blue:80.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Light Green",
               @"color":[UIColor colorWithRed:139.0/255.0f green:195.0/255.0f blue:74.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Lime",
               @"color":[UIColor colorWithRed:205.0/255.0f green:220.0/255.0f blue:57.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Yellow",
               @"color":[UIColor colorWithRed:255.0/255.0f green:235.0/255.0f blue:59.0/255.0f alpha:1.0f]},
             
             
             
             @{@"name":@"Indigo",
               @"color":[UIColor colorWithRed:63.0/255.0f green:81.0/255.0f blue:181.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Blue Gray",
               @"color":[UIColor colorWithRed:96.0/255.0f green:125.0/255.0f blue:139.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Blue",
               @"color":[UIColor colorWithRed:33.0/255.0f green:150.0/255.0f blue:243.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Light Blue",
               @"color":[UIColor colorWithRed:3.0/255.0f green:169.0/255.0f blue:244.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Cyan",
               @"color":[UIColor colorWithRed:0.0/255.0f green:188.0/255.0f blue:212.0/255.0f alpha:1.0f]},
             
             
             
             @{@"name":@"Deep Purple",
               @"color":[UIColor colorWithRed:103.0/255.0f green:58.0/255.0f blue:183.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Purple",
               @"color":[UIColor colorWithRed:156.0/255.0f green:39.0/255.0f blue:176.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Pink",
               @"color":[UIColor colorWithRed:233.0/255.0f green:30.0/255.0f blue:99.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Tomato",
               @"color":[UIColor  colorWithRed:255.0/255.0f green:99.0/255.0f blue:71.0/255.0f alpha:1.0f]},
             
             @{@"name":@"Wheat",
               @"color":[UIColor colorWithRed:255.0/255.0f green:222.0/255.0f blue:179.0/255.0f alpha:1.0f]},
             ];
}


- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self setupColorButtons];
}

- (void)setButtonDiameter:(CGFloat)buttonDiameter
{
    _buttonDiameter = buttonDiameter;
    [self calculateButtonFrames];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if(selectedIndex >= _colorButtons.count)
        selectedIndex = _colorButtons.count - 1;
    
    _selectedIndex = selectedIndex;
    
    HFColorButton* button = [_colorButtons objectAtIndex:selectedIndex];
    [self selectButton:button];
}

- (CGFloat)buttonDiameter
{
    if(_buttonDiameter == 0.0)
        _buttonDiameter = 40.0;
    return _buttonDiameter;
}

-(NSUInteger)numberOfColorsPerRow
{
    if (_numberOfColorsPerRow == 0)
        _numberOfColorsPerRow = 5;
    
    return _numberOfColorsPerRow;
}

- (NSMutableArray*)colorButtons
{
    if(_colorButtons == nil)
        _colorButtons = [NSMutableArray new];
    return _colorButtons;
}

- (void)setupColorButtons
{
    // remove all buttons
    for (HFColorButton* button in self.colorButtons)
    {
        [button removeFromSuperview];
    }
    [_colorButtons removeAllObjects];
    
    CGFloat buttonCount = 0;
    
    // create new buttons
    for (UIColor* color in _colors)
    {
        HFColorButton* button = [HFColorButton new];
        [button setColor:color];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setClipsToBounds:NO];
        
        if(buttonCount == 0)
            button.selected = YES;
        buttonCount++;
        
        [self addSubview:button];
        [_colorButtons addObject:button];
    }
    
    [self calculateButtonFrames];
}

-(void)layoutSubviews
{
    [self calculateButtonFrames];
}

- (void)calculateButtonFrames
{
    NSInteger buttonCount = self.colorButtons.count;
    
    NSInteger buttonsPerRow = self.numberOfColorsPerRow;
    if(buttonsPerRow > buttonCount)
        buttonsPerRow = buttonCount;
    
    NSInteger numberOfRows = ceil((CGFloat)buttonCount/(CGFloat)buttonsPerRow);

    CGFloat buttonWidth = self.buttonDiameter;
    CGFloat rowWidth = self.frame.size.width/buttonsPerRow;
    CGFloat rowHeight = self.frame.size.height/numberOfRows;

    CGFloat i = 0;
    CGFloat j = 0;
    
    NSInteger currentIndex = 0;
    for (HFColorButton* button in self.colorButtons)
    {
        button.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
        button.center = CGPointMake(i * rowWidth + rowWidth/2,
                                    j * rowHeight + rowHeight/2);
        
        currentIndex++;
        j = currentIndex/buttonsPerRow;
        i = currentIndex%buttonsPerRow;
    }
}

- (void)buttonClicked:(id)sender
{
    NSInteger index = [_colorButtons indexOfObject:sender];
    if(index >= 0)
    {
        [self selectButton:sender];
        
        UIColor* color = [_colors objectAtIndex:index];
        if(_delegate != nil)
            [_delegate colorPicker:self selectedColor:color];
    }
}

- (void)selectButton:(HFColorButton *)button
{
    for (HFColorButton* button in self.colorButtons)
    {
        button.selected = NO;
    }
    button.selected = YES;
}

@end
