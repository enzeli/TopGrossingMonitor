//
//  TGRSSTableViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/8/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGRSSAppTableViewController.h"


@interface TGRSSAppTableViewController ()

@end

@implementation TGRSSAppTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *requestString = @"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topgrossingapplications/sf=143441/limit=25/json";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      // stop indicator first
                                      [self.activityIndicator stopAnimating];
                                      [self.activityIndicator removeFromSuperview];
                                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                      
                                      // request unsuccessful
                                      if (error) {
                                          NSLog(@"HTTP request error: %@", error);
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                                                              message:@"Connection failed. Check your network settings."
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                          [alertView show];
                                          
                                      }
                                      
                                      // request complete
                                      else {
                                          id jsondata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          
                                          if (jsondata[@"feed"][@"entry"]) {
                                              if ([jsondata[@"feed"][@"entry"] isKindOfClass:[NSArray class]]) {
                                                  self.dataSource = jsondata[@"feed"][@"entry"];
                                                  [self.tableView reloadData];
                                              }
                                          } else {
                                              NSLog(@"JSONSerialization error: %@", error);
                                          }
                                      }
                                      

                                  }];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
    [task resume];
    
}

- (NSDictionary *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dataSource[indexPath.row];
}


@end
