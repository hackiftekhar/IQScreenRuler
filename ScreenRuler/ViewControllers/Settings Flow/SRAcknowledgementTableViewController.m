//
//  AcknowledgementTableViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRAcknowledgementTableViewController.h"
#import "SRLicenseTableViewCell.h"
#import <SafariServices/SafariServices.h>
#import "UIColor+ThemeColor.h"

@interface SRAcknowledgementTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray<NSDictionary<NSString*,id>*> *listArray;
}

@end

@implementation SRAcknowledgementTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.title = NSLocalizedString(@"open_source_libraries", nil);

    NSString *path=[[NSBundle mainBundle] pathForResource:@"Acknowledgement" ofType:@".plist"];
    listArray = [[NSArray alloc] initWithContentsOfFile:path];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [listArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary<NSString*,id> *dict = listArray[section];
    return dict[@"Title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary<NSString*,id> *dict = listArray[section];
    NSArray <NSDictionary<NSString*,NSString*>*> *subItem = dict[@"SubItem"];
    return subItem.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SRLicenseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SRLicenseTableViewCell class]) forIndexPath:indexPath];

    NSDictionary<NSString*,NSString*> *item = listArray[indexPath.section][@"SubItem"][indexPath.row];

    cell.labelTitle.text = [NSString stringWithFormat:@"%ld) %@",indexPath.row+1,item[@"Title"]];
    
    NSString *linkText = item[@"Link"];
    [cell.buttonLink setTitle:linkText forState:UIControlStateNormal];
    [cell.buttonLink addTarget:self action:@selector(linkAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.buttonLink.hidden = ([linkText length] == 0);
    cell.labelLicenseType.text = item[@"License"];
    cell.labelDescription.text = item[@"Description"];

    return cell;
}

-(void)linkAction:(UIButton*)sender
{
    NSString *text = [sender titleForState:UIControlStateNormal];
    NSURL *url = [NSURL URLWithString:text];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
        
        if ([controller respondsToSelector:@selector(preferredBarTintColor)])
        {
            [controller setPreferredBarTintColor:[UIColor themeColor]];
        }
        
        if ([controller respondsToSelector:@selector(preferredControlTintColor)])
        {
            [controller setPreferredControlTintColor:[UIColor themeTextColor]];
        }
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
