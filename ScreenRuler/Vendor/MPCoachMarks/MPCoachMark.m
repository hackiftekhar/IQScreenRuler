//
//  MPCoachMark.m
//  Example
//
//  Created by marcelo.perretta@gmail.com on 7/8/15.
//  Copyright (c) 2015 MAWAPE. All rights reserved.
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MPCoachMark.h"

@implementation MPCoachMark

-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self)
    {
        self.view = [attributes objectForKey:@"view"];
        self.rect = [[attributes objectForKey:@"rect"] CGRectValue];
        self.inset = ([attributes objectForKey:@"inset"])?[[attributes objectForKey:@"inset"] UIEdgeInsetsValue]:UIEdgeInsetsMake(-10, -10, -10, -10);
        self.borderColor = [attributes objectForKey:@"borderColor"];

        self.beginInterval = [[attributes objectForKey:@"beginInterval"] doubleValue];

        self.caption = [attributes objectForKey:@"caption"];
        self.shape = [[attributes objectForKey:@"shape"] integerValue];
        self.position = [[attributes objectForKey:@"position"] integerValue];
        self.alignment = [[attributes objectForKey:@"alignment"] integerValue];
        self.image = [[attributes objectForKey:@"image"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.cutoutRadius = ([attributes objectForKey:@"cutoutRadius"])?[[attributes objectForKey:@"cutoutRadius"] floatValue]:5.0;
    }

    return self;
}

+(instancetype)markWithAttributes:(NSDictionary*)attributes
{
    return [[self alloc] initWithAttributes:attributes];
}

@end
