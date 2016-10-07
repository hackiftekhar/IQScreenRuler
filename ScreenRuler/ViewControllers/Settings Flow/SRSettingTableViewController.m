//
//  SRSettingTableViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRSettingTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "SRAcknowledgementTableViewController.h"
#import "SRPrivacyPolicyViewController.h"
#import <StoreKit/StoreKit.h>
#import "UIColor+ThemeColor.h"
#import "UIColor+HexColors.h"
#import "SRThemeTableViewCell.h"
#import "SRSettingsTableViewCell.h"

@interface SRSettingTableViewController ()<MFMailComposeViewControllerDelegate,SKStoreProductViewControllerDelegate>
{
    NSString *appName;
    NSString *versionString;
    IBOutlet UILabel *versionLabel;
    IBOutlet UILabel *labelCompanyName;
    
    NSArray<NSDictionary<NSString*,id>*> *settingsItems;
}

@end

@implementation SRSettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.title = NSLocalizedString(@"Settings", nil);
    
    settingsItems = @[@{@"title":NSLocalizedString(@"Settings", nil),@"items":@[@{@"title":NSLocalizedString(@"Color Theme", nil),@"discloseIndicator":@NO}]},
                      @{@"title":NSLocalizedString(@"Social", nil),@"items":@[@{@"title":NSLocalizedString(@"Share On Social Network", nil),@"discloseIndicator":@NO},@{@"title":NSLocalizedString(@"Rate Us On App Store", nil),@"discloseIndicator":@NO}]},
                      @{@"title":NSLocalizedString(@"Feedback", nil),@"items":@[@{@"title":NSLocalizedString(@"Feedback", nil),@"discloseIndicator":@NO},@{@"title":NSLocalizedString(@"Bug Report", nil),@"discloseIndicator":@NO}]},
                      @{@"title":NSLocalizedString(@"Terms", nil),@"items":@[@{@"title":NSLocalizedString(@"Terms and Conditions", nil),@"discloseIndicator":@YES},@{@"title":NSLocalizedString(@"Open Source Libraries", nil),@"discloseIndicator":@YES}]}];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleDone target:nil action:nil];
    
    NSDictionary *localizedInfoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
    NSMutableDictionary *infoDictionary = [[[NSBundle mainBundle] infoDictionary] mutableCopy];
    [infoDictionary addEntriesFromDictionary:localizedInfoDictionary];

    appName = [infoDictionary objectForKey:@"CFBundleName"];
    
    {
        NSString* shortVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        NSMutableArray *versionArray = [[shortVersionString componentsSeparatedByString:@"."] mutableCopy];
        
        for (NSInteger i = 0; i<versionArray.count; i++)
        {
            NSString *version = [versionArray objectAtIndex:i];
            [versionArray replaceObjectAtIndex:i withObject:[NSString localizedStringWithFormat:@"%ld",(long)[version integerValue]]];
        }
        
        versionString = [versionArray componentsJoinedByString:[[NSLocale currentLocale] decimalSeparator]];
    }

    versionLabel.text =[NSString localizedStringWithFormat:@"%@ %@",NSLocalizedString(@"Version", nil),versionString];
    labelCompanyName.text = NSLocalizedString(@"InfoEnum Software Systems", nil);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor themeColor];
    self.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
    self.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];

    [self.tableView reloadData];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (IBAction)themeColorAction:(HFColorButton *)sender
{
    [UIColor setThemeColor:sender.color];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBar.barTintColor = [UIColor themeColor];
        self.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
        self.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];
        [self.tableView reloadData];
    }];
}

- (IBAction)segmentColorAction:(UISegmentedControl *)sender
{
    [UIColor setThemeInverted:sender.selectedSegmentIndex];

    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBar.barTintColor = [UIColor themeColor];
        self.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
        self.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];
        sender.tintColor = [UIColor originalThemeColor];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingsItems.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return settingsItems[section][@"title"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settingsItems[section][@"items"] count];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 155;
    }
    else
    {
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SRThemeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SRThemeTableViewCell class]) forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        for (HFColorButton *button in cell.themeColorButtons)
        {
            button.backgroundColor = nil;
            
            NSString *buttonHexValue = [button.color hexValue];
            NSString *selectedHexValue = [[UIColor originalThemeColor] hexValue];
            
            button.selected = ([selectedHexValue isEqualToString:buttonHexValue]);
        }
        
        cell.segmentControl.selectedSegmentIndex = [UIColor isThemeInverted];
        cell.segmentControl.tintColor = [UIColor originalThemeColor];

        return cell;
    }
    else
    {
        SRSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SRSettingsTableViewCell class]) forIndexPath:indexPath];
        
        NSDictionary *dict = settingsItems[indexPath.section][@"items"][indexPath.row];
        
        cell.textLabel.text = dict[@"title"];
        cell.accessoryType = [dict[@"discloseIndicator"] boolValue]?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section)
    {
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    //Share With UIActivityViewController
                    NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"social_share_text", nil),appName];
                    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/id1104790987"];
                    
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[messageBody,url] applicationActivities:nil];
                    [self presentViewController:activityController animated:YES completion:nil];
                }//case 1
                    break;
                    
                case 1:
                {
                    SKStoreProductViewController* skpvc = [[SKStoreProductViewController alloc] init];
                    skpvc.delegate = self;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject: @(1104790987) forKey: SKStoreProductParameterITunesItemIdentifier];
                    [skpvc loadProductWithParameters: dict completionBlock:^(BOOL result, NSError * _Nullable error) {

                        if (result == NO && error != nil)
                        {
                            [skpvc dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                    [self presentViewController: skpvc animated: YES completion: nil];
                }//case 2
                    break;
            }
            
        }//case 0
            break;
            
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    // feedback
                    if(![MFMailComposeViewController canSendMail])
                    {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"mail_device_configuration_message", nil) preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                        
                        [alertController addAction:actionOk];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else
                    {
                        NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"mail_body", nil),[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],versionString,appName];
                        
                        NSArray *emailAdd = [NSArray arrayWithObject: @"info@infoenum.com"];
                        
                        MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
                        messageController.mailComposeDelegate = self;
                        
                        [messageController setSubject:NSLocalizedString(@"Screen Ruler - Feedback", nil)];
                        [messageController setMessageBody:messageBody isHTML:NO];
                        [messageController setToRecipients:emailAdd];
                        
                        [self presentViewController:messageController animated:YES completion:NULL];
                    }
                }//case 0
                    break;
                case 1:
                {
                    //Bug Report
                    
                    if(![MFMailComposeViewController canSendMail])
                    {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"mail_device_configuration_message", nil) preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                        
                        [alertController addAction:actionOk];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else
                    {
                        
                        NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"mail_body", nil),[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],versionString,appName];
                        
                        NSArray *emailAdd = [NSArray arrayWithObject: @"info@infoenum.com"];
                        MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
                        messageController.mailComposeDelegate = self;
                        
                        [messageController setSubject:NSLocalizedString(@"Screen Ruler - Bug Report", nil)];
                        [messageController setMessageBody:messageBody isHTML:NO];
                        [messageController setToRecipients:emailAdd];
                        
                        [self presentViewController:messageController animated:YES completion:NULL];
                    }
                }//case 1
                    break;
            }
        }
            break;
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self performSegueWithIdentifier:NSStringFromClass([SRPrivacyPolicyViewController class]) sender:self];
                }
                    break;
                case 1:
                {
                    [self performSegueWithIdentifier:NSStringFromClass([SRAcknowledgementTableViewController class]) sender:self];
                }
                    break;
            }
        }
        break;
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        
        case MFMailComposeResultSent:{
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Mail Sent", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;

        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma Action

- (IBAction)doneButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
