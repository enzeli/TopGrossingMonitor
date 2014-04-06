//
//  TGFavTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGFavTableViewController.h"
#import "FavDataManager.h"
#import "TGAppViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import CoreData;

@interface TGFavTableViewController ()

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation TGFavTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchFavourites];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    // reload if favourites has updated
    if ([[FavDataManager sharedInstance] hasUpdated]){
        [self fetchFavourites];
    }
    
}

- (void)fetchFavourites{
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"App"
                                                         inManagedObjectContext:context];
    [request setEntity:entityDescription];
    [request setPredicate:nil];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    self.dataSource = results;
    
    NSLog(@"%d results fetched.", results.count);
    [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavAppCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSData *rawJSONData = [self.dataSource[indexPath.row] valueForKey:@"data"];
    NSError *error;
    NSDictionary *celldata = [NSJSONSerialization JSONObjectWithData:rawJSONData options:NSJSONReadingMutableContainers error:&error];
    
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
            
            NSData *rawJSONData = [self.dataSource[indexPath.row] valueForKey:@"data"];
            NSError *error;
            NSDictionary *celldata = [NSJSONSerialization JSONObjectWithData:rawJSONData options:NSJSONReadingMutableContainers error:&error];
            
            receiver.data = celldata;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
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
