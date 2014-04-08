//
//  TGRSSTableViewController.h
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/8/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//
//
//  Extended from TGAppTableViewController to display app items from RSS feed
//

#import "TGAppTableViewController.h"

@interface TGRSSAppTableViewController : TGAppTableViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
