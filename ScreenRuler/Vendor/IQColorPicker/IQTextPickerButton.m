//
//  IQTextPickerButton.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "IQTextPickerButton.h"

@interface IQTextPickerButton ()<UIPickerViewDelegate,UIPickerViewDataSource>

@end


@implementation IQTextPickerButton
{
    UIPickerView *pickerView;
}

-(void)initialize
{
    self.selected = YES;
    
    pickerView = [[UIPickerView alloc] init];
    [pickerView sizeToFit];
    pickerView.delegate = self;
    
    self.inputView = pickerView;
    
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
        
        [self addTarget:self action:@selector(textPickerTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.tintColor = [UIColor clearColor];
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

-(void)textPickerTapped:(IQTextPickerButton*)textPicker
{
    [self becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)becomeFirstResponder
{
    if (_selectedItem)
    {
        [pickerView selectRow:[_items indexOfObject:_selectedItem] inComponent:0 animated:YES];
    }

    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    self.selectedItem = _items[[pickerView selectedRowInComponent:0]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return [super resignFirstResponder];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _items.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _items[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedItem = _items[row];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)setSelectedItem:(NSString *)selectedItem
{
    for (NSString *item in _items)
    {
        if ([item isEqualToString:selectedItem])
        {
            _selectedItem = selectedItem;
            [self setTitle:item forState:UIControlStateNormal];
            [pickerView selectRow:[_items indexOfObject:selectedItem] inComponent:0 animated:YES];
            break;
        }
    }
}

@end
