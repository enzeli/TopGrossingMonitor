//
//  TGTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGRSSTableViewController.h"
#import "AFNetworking.h"
#import "TGAppViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TGRSSTableViewController ()

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation TGRSSTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *requestString = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topgrossingapplications/sf=143441/limit=25/json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dataSource = responseObject[@"feed"][@"entry"];
//        NSLog(@"%@", responseObject[@"feed"][@"entry"][0]);
//        NSLog(@"Name: %@", responseObject[@"feed"][@"entry"][0][@"im:name"][@"label"]);
//        NSLog(@"Price: %@", responseObject[@"feed"][@"entry"][0][@"im:price"][@"attributes"][@"amount"]);
//        NSLog(@"Link: %@", responseObject[@"feed"][@"entry"][0][@"link"][@"attributes"][@"href"]);
        
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *celldata = self.dataSource[indexPath.row];
    
    cell.textLabel.text = celldata[@"im:name"][@"label"];
    cell.detailTextLabel.text = celldata[@"im:artist"][@"label"];
    
    NSURL *imageURL = [NSURL URLWithString:celldata[@"im:image"][1][@"label"]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [cell.imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PushDetailSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[TGAppViewController class]]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            TGAppViewController *receiver = (TGAppViewController *)segue.destinationViewController;
            receiver.data = self.dataSource[indexPath.row];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
}

#pragma mark - tab bar delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    int tabitem = tabBarController.selectedIndex;
    if (tabitem == 1) {
        // a easy fix to small bug
        [[tabBarController.viewControllers objectAtIndex:tabitem] popToRootViewControllerAnimated:YES];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
