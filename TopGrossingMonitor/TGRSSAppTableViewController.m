//
//  TGRSSTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/8/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGRSSAppTableViewController.h"
#import "AFNetworking.h"



@interface TGRSSAppTableViewController ()

@end

@implementation TGRSSAppTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *requestString = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topgrossingapplications/sf=143441/limit=25/json";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
    
    
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dataSource = responseObject[@"feed"][@"entry"];
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (NSDictionary *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dataSource[indexPath.row];
}


@end
