//
//  SROnboardingZoomController.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 12/01/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SROnboardingZoomController.h"

@interface SROnboardingZoomController ()

@end

@implementation SROnboardingZoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    label.text = @"zoom";
    label.backgroundColor = [UIColor greenColor];
    [self.view addSubview:label];
    NSLog(@"%@",self.view);
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
