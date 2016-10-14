//
//  AcknowledgementTableViewController.m
//  Screen Ruler
//
//  Created by Mohd Iftekhar Qurashi
//  Copyright (c) 2016 InfoEum Software Systems. Licensed under the Apache License v2.0.
//  See COPYING or https://www.apache.org/licenses/LICENSE-2.0

#import "SRAcknowledgementTableViewController.h"
#import "SRAcknowledgementDetailsViewController.h"

@interface SRAcknowledgementTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSDictionary *listDictionary;
    NSArray *allkeys;
}

@end

@implementation SRAcknowledgementTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.title = NSLocalizedString(@"open_source_libraries", nil);

    NSString *path=[[NSBundle mainBundle] pathForResource:@"Acknowledgement" ofType:@".plist"];
    listDictionary=[[NSDictionary alloc] initWithContentsOfFile:path];
    allkeys=[listDictionary allKeys];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [listDictionary count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = [allkeys objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self performSegueWithIdentifier:NSStringFromClass([SRAcknowledgementDetailsViewController class]) sender:indexPath];
}
#pragma mark -  Actions
- (IBAction)doneAcitons:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = sender;
    
    NSString *title = [allkeys objectAtIndex:indexPath.row];
    NSString *description = [listDictionary objectForKey:[allkeys objectAtIndex:indexPath.row]];

    SRAcknowledgementDetailsViewController *ackVC=[segue destinationViewController];
    ackVC.ackDescription=description;
    ackVC.navigationItem.title = title;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
