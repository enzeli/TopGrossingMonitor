//
//  TGTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGAppTableViewController.h"
#import "TGAppViewController.h"
#import "UIImageView+WebCache.h"

@interface TGAppTableViewController ()

@end

@implementation TGAppTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.dataSource.count;
}

// to be override by sublasses
- (NSDictionary *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *celldata = [self dataAtIndexPath:indexPath];
    
    cell.textLabel.text = celldata[@"im:name"][@"label"];
    cell.detailTextLabel.text = celldata[@"im:artist"][@"label"];
    
    NSURL *imageURL = [NSURL URLWithString:[celldata[@"im:image"] lastObject][@"label"]];
    
    if (imageURL) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [cell.imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    return cell;

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PushDetailSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[TGAppViewController class]]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            TGAppViewController *receiver = (TGAppViewController *)segue.destinationViewController;
            receiver.data = [self dataAtIndexPath:indexPath];

            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        id detailvc = [self.splitViewController.viewControllers lastObject];
        if ([detailvc isKindOfClass:[UINavigationController class]]) {
            
            detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
            if ([detailvc isKindOfClass:[TGAppViewController class]]){
                TGAppViewController *receiver = (TGAppViewController *)detailvc;
                receiver.data = [self dataAtIndexPath:indexPath];
                [receiver reloadView];
            }

        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
