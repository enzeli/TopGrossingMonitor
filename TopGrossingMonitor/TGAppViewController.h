//
//  TGAppViewController.h
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;

@interface TGAppViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *data;

@end
