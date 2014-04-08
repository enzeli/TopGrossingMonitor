//
//  TGTableViewController.h
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//
//  A generic class for displaying app items in tabelview
//  Subclasses should override |viewDidLoad| for loading dataSource upon loading
//                   and |dataAtIndexPath:| for providing formatted data points
//
//  Data point format: JSON object of a single app as NSDictionary
//


#import <UIKit/UIKit.h>

@interface TGAppTableViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;

@end
