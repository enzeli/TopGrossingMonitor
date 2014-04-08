//
//  TGFavAppTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/8/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGFavAppTableViewController.h"
#import "FavDataManager.h"

@import CoreData;


@interface TGFavAppTableViewController ()

@end

@implementation TGFavAppTableViewController


- (void)loadData
{
    [self fetchFavourites];
}

// load dataSource from Core Data
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // reload data only if favourites has updated
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
    
    [self.tableView reloadData];
}


- (NSDictionary *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    NSData *rawJSONData = [self.dataSource[indexPath.row] valueForKey:@"data"];
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:rawJSONData options:NSJSONReadingMutableContainers error:&error];
    return data;
}




@end
