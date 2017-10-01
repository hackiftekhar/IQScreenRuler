//
//  SROnboardingNavigationController.m
//  Screen Ruler
//
//  Created by IEMacBook02 on 12/01/17.
//  Copyright © 2017 InfoEnum Software Systems. All rights reserved.
//

#import "SROnboardingNavigationController.h"
#import "SROnboardingWelcomeController.h"
#import "SROnboardingZoomController.h"

@interface SROnboardingNavigationController ()

@end

@implementation SROnboardingNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@",self.view.subviews);
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(50, 500, 100, 100);
    [button setTitle:@"next" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 100, 100)];
    label.text = @"Welcome navigation top";
    label.backgroundColor = [UIColor greenColor];
    [self.view addSubview:label];
    NSLog(@"%@",self.view);

    SROnboardingWelcomeController *welcomeController = [[SROnboardingWelcomeController alloc] init];
    self.viewControllers = @[welcomeController];
    [self setNavigationBarHidden:YES];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 350, 100, 100)];
    label2.text = @"Welcome navigation bottom";
    label2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:label2];
    NSLog(@"%@",self.view);

    NSLog(@"%@",self.view.subviews);
}

-(void)nextAction:(UIButton*)sender
{
    SROnboardingZoomController *controller = [[SROnboardingZoomController alloc] init];
    
    UIViewController *topController = self.topViewController;
    
    [UIView transitionFromView:topController.view toView:controller.view duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
    }];

    [self pushViewController:controller animated:NO];
}


@end
