//
//  AcknowledgementTableViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRAcknowledgementTableViewController.h"
#import "SRLicenseTableViewCell.h"

@interface SRAcknowledgementTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray<NSDictionary<NSString*,id>*> *listArray;
//    NSArray *allkeys;
}

@end

@implementation SRAcknowledgementTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.title = NSLocalizedString(@"open_source_libraries", nil);

    NSString *path=[[NSBundle mainBundle] pathForResource:@"Acknowledgement" ofType:@".plist"];
    listArray = [[NSArray alloc] initWithContentsOfFile:path];
//    allkeys=[listDictionary allKeys];
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

    cell.labelTitle.text = item[@"Title"];
    
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"open_safari?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"open", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:url];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:actionOk];
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
