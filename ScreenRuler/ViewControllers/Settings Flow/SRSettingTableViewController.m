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
#import "UIFont+AppFont.h"
#import "UIColor+HexColors.h"
#import "SRThemeTableViewCell.h"
#import "SRSettingsTableViewCell.h"
#import "SRVersionTableViewCell.h"
#import <Crashlytics/Answers.h>
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"

@interface SRSettingTableViewController ()<MFMailComposeViewControllerDelegate,SKStoreProductViewControllerDelegate>
{
    NSString *appName;
    NSString *versionString;
    IBOutlet UILabel *versionLabel;
    IBOutlet UILabel *labelCompanyName;
    IBOutlet UILabel *labelOpenSource;
    
    NSArray<NSDictionary<NSString*,id>*> *settingsItems;
}

@end

@implementation SRSettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.title = NSLocalizedString(@"settings", nil);
    
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
    
    UISwitch *showZoomOptionSwitch = [[UISwitch alloc] init];
    [showZoomOptionSwitch addTarget:self action:@selector(showZoomOptionAction:) forControlEvents:UIControlEventValueChanged];
    showZoomOptionSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowZoomOption"];
    settingsItems = @[@{@"title":NSLocalizedString(@"settings", nil),@"items":@[@{@"title":NSLocalizedString(@"color_theme", nil)},@{@"title":NSLocalizedString(@"show_zoom_options", nil),@"accessoryView":showZoomOptionSwitch}]},
                      @{@"title":NSLocalizedString(@"version", nil),@"items":@[@{@"title":NSLocalizedString(@"you_are_upto_date", nil),@"subtitle":versionString}]},
                      @{@"title":NSLocalizedString(@"social", nil),@"items":@[@{@"title":NSLocalizedString(@"share_on_social_network", nil)},@{@"title":NSLocalizedString(@"rate_us_on_app_store", nil)}]},
                      @{@"title":NSLocalizedString(@"feedback", nil),@"items":@[@{@"title":NSLocalizedString(@"feedback", nil)},@{@"title":NSLocalizedString(@"bug_report", nil)}]},
                      @{@"title":NSLocalizedString(@"terms", nil),@"items":@[@{@"title":NSLocalizedString(@"terms_and_conditions", nil),@"discloseIndicator":@YES},@{@"title":NSLocalizedString(@"open_source_libraries", nil),@"discloseIndicator":@YES}]}];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:nil action:nil];

    NSString *openSourceString = [NSString stringWithFormat:@"%@ %@",appName,NSLocalizedString(@"is_open_source_at", nil)];
    NSMutableAttributedString *openSourceAttributedString = [[NSMutableAttributedString alloc] initWithString:openSourceString attributes:nil];
    [openSourceAttributedString addAttribute:NSFontAttributeName value:[UIFont kohinoorBanglaSemiboldWithSize:15] range:[openSourceString rangeOfString:appName]];
    
    labelOpenSource.attributedText = openSourceAttributedString;
    versionLabel.text =[NSString localizedStringWithFormat:@"%@ %@",NSLocalizedString(@"version", nil),versionString];
    labelCompanyName.text = NSLocalizedString(@"infoenum_software_systems", nil);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor themeColor];
    self.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
    self.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iVersionDidUpdateNotification:) name:iVersionDidUpdateNotification object:nil];

    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:iVersionDidUpdateNotification object:nil];
}

-(void)iVersionDidUpdateNotification:(NSNotification*)notification
{
    [self.tableView reloadData];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (IBAction)themeColorAction:(HFColorButton *)sender
{
    [UIColor setThemeColor:sender.color];
    
    [Answers logCustomEventWithName:@"Theme Changed" customAttributes:nil];

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.navigationController.navigationBar.barTintColor = [UIColor themeColor];
        weakSelf.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
        weakSelf.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];
        [weakSelf.tableView reloadData];
    }];
}

- (IBAction)segmentColorAction:(UISegmentedControl *)sender
{
    [UIColor setThemeInverted:sender.selectedSegmentIndex];

    [Answers logCustomEventWithName:@"Theme Inverted" customAttributes:@{@"Inverted":@(sender.selectedSegmentIndex)}];

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.navigationController.navigationBar.barTintColor = [UIColor themeColor];
        weakSelf.navigationController.navigationBar.tintColor = [UIColor themeTextColor];
        weakSelf.navigationController.navigationBar.barStyle = ![UIColor isThemeInverted];
        sender.tintColor = [UIColor originalThemeColor];
    }];
}

-(void)showZoomOptionAction:(UISwitch*)aSwitch
{
    [Answers logCustomEventWithName:@"Theme Inverted" customAttributes:@{@"Show":@(aSwitch.on)}];

    [[NSUserDefaults standardUserDefaults] setBool:aSwitch.on forKey:@"ShowZoomOption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)openSourceAtGithubAction:(UIButton *)sender {
    
    [Answers logCustomEventWithName:@"Open Repository Safari" customAttributes:nil];

    NSURL *url = [NSURL URLWithString:@"https://github.com/hackiftekhar/IQScreenRuler"];
    
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
    if (indexPath.section == 0 && indexPath.row == 0)
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
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        SRVersionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SRVersionTableViewCell class]) forIndexPath:indexPath];
        
        NSDictionary *dict = settingsItems[indexPath.section][@"items"][indexPath.row];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.updatedVersionString)
        {
            cell.textLabel.text = NSLocalizedString(@"update_now", nil);
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.textLabel.text = dict[@"title"];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (appDelegate.isCheckingNewVersion)
        {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            cell.accessoryView = activityIndicator;
            cell.detailTextLabel.text = nil;
        }
        else
        {
            cell.accessoryView = nil;
            if (appDelegate.updatedVersionString)
            {
                cell.detailTextLabel.text = appDelegate.updatedVersionString;
            }
            else
            {
                cell.detailTextLabel.text = dict[@"subtitle"];
            }
        }
        
        return cell;
    }
    else
    {
        SRSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SRSettingsTableViewCell class]) forIndexPath:indexPath];
        
        NSDictionary *dict = settingsItems[indexPath.section][@"items"][indexPath.row];
        
        cell.textLabel.text = dict[@"title"];
        cell.detailTextLabel.text = dict[@"subtitle"];
        cell.accessoryType = [dict[@"discloseIndicator"] boolValue]?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
        cell.accessoryView = dict[@"accessoryView"];
        
        if ([cell.accessoryView isKindOfClass:[UISwitch class]])
        {
            UISwitch *accessoryView = (UISwitch*)cell.accessoryView;
            accessoryView.onTintColor = [UIColor originalThemeColor];
        }
        
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
                    SKStoreProductViewController* skpvc = [[SKStoreProductViewController alloc] init];
                    skpvc.delegate = self;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject: @(kSRAppStoreID) forKey: SKStoreProductParameterITunesItemIdentifier];
                    [skpvc loadProductWithParameters: dict completionBlock:^(BOOL result, NSError * _Nullable error) {
                        
                        if (result == NO && error != nil)
                        {
                            [skpvc dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                    [self presentViewController: skpvc animated: YES completion: nil];
                }
                    break;
            }
        }
            break;

        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [Answers logShareWithMethod:@"Social Share" contentName:@"Share Activity" contentType:@"share" contentId:@"share.app" customAttributes:nil];

                    //Share With UIActivityViewController
                    NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"social_share_text", nil),appName];
                    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/id1104790987"];
                    
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[messageBody,url] applicationActivities:nil];
                    [self presentViewController:activityController animated:YES completion:nil];
                }//case 1
                    break;
                    
                case 1:
                {
                    [Answers logCustomEventWithName:@"Rate Us" customAttributes:nil];
                    
                    SKStoreProductViewController* skpvc = [[SKStoreProductViewController alloc] init];
                    skpvc.delegate = self;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject: @(kSRAppStoreID) forKey: SKStoreProductParameterITunesItemIdentifier];
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
        }
            break;
            
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    // feedback
                    if(![MFMailComposeViewController canSendMail])
                    {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"mail_device_configuration_message", nil) preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                        
                        [alertController addAction:actionOk];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else
                    {
                        [Answers logCustomEventWithName:@"Feedback" customAttributes:nil];

                        NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"mail_body", nil),[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],versionString,appName];
                        
                        NSArray *emailAdd = [NSArray arrayWithObject: @"info@infoenum.com"];
                        
                        MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
                        messageController.mailComposeDelegate = self;
                        
                        [messageController setSubject:NSLocalizedString(@"screen_ruler_feedback", nil)];
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
                        
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                        
                        [alertController addAction:actionOk];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else
                    {
                        [Answers logCustomEventWithName:@"Bug Report" customAttributes:nil];
                        
                        NSString *messageBody =[NSString localizedStringWithFormat:NSLocalizedString(@"mail_body", nil),[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],versionString,appName];
                        
                        NSArray *emailAdd = [NSArray arrayWithObject: @"info@infoenum.com"];
                        MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
                        messageController.mailComposeDelegate = self;
                        
                        [messageController setSubject:NSLocalizedString(@"screen_ruler_bug_report", nil)];
                        [messageController setMessageBody:messageBody isHTML:NO];
                        [messageController setToRecipients:emailAdd];
                        
                        [self presentViewController:messageController animated:YES completion:NULL];
                    }
                }//case 1
                    break;
            }
        }
            break;
        case 4:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [Answers logCustomEventWithName:@"Privacy Policy" customAttributes:nil];
                    [self performSegueWithIdentifier:NSStringFromClass([SRPrivacyPolicyViewController class]) sender:self];
                }
                    break;
                case 1:
                {
                    [Answers logCustomEventWithName:@"Open Source Libraries" customAttributes:nil];
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
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"mail_sent", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
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
