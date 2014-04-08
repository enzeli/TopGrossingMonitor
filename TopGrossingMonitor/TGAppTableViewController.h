//
//  TGTableViewController.h
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <UIKit/UIKit.h>

// A generic class for displaying app in tabelview
// Subclasses should override |viewDidLoad| for loading dataSource
//                   and |dataAtIndexPath:| for providing data points


@interface TGAppTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *dataSource;

@end
