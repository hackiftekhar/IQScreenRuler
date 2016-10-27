//
//  SRIconsGeneratorViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRIconsGeneratorViewController.h"

@interface SRIconsGeneratorViewController ()

@property (strong, nonatomic) IBOutlet UIView *lineFrameView;
@property (strong, nonatomic) IBOutlet UIView *cropView;
@property (strong, nonatomic) IBOutlet UIView *aspectRatioView;
@property (strong, nonatomic) IBOutlet UIView *resizeView;
@property (strong, nonatomic) IBOutlet UIView *humbergerView;
@property (strong, nonatomic) IBOutlet UIView *scaleView;

@property (strong, nonatomic) IBOutlet UIView *freeScaleContainerView;
@property (strong, nonatomic) IBOutlet UIView *freeScaleview;


@end

@implementation SRIconsGeneratorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.freeScaleview.transform = CGAffineTransformMakeRotation(M_PI_2*3);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@",self.freeScaleview);
    NSLog(@"%@",self.scaleView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
