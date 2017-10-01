//
//  SROnboardingWelcomeController.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 12/01/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SROnboardingWelcomeController.h"

@interface SROnboardingWelcomeController ()

@end

@implementation SROnboardingWelcomeController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    label.text = @"Welcome";
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
