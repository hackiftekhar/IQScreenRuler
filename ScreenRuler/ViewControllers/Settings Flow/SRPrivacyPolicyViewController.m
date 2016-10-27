//
//  SRPrivacyPolicyViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRPrivacyPolicyViewController.h"

@interface SRPrivacyPolicyViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation SRPrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"terms_and_conditions", nil);

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"EULA" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];

}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (IBAction)doneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

@end
