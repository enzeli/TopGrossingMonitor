//
//  TGAppViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGAppDetailViewController.h"
#import "TGFavAppTableViewController.h"
#import "FavDataManager.h"
#import "App.h"
#import "UIImageView+WebCache.h"
@import CoreData;
@import Social;

@interface TGAppDetailViewController ()

@property (assign) BOOL isFav;
@property (strong, nonatomic) UIImageView *welcomeImageView;
@property (strong, nonatomic) UIBarButtonItem *rightButton;

@end

@implementation TGAppDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add fav button on Navigation bar
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(favButtonPressed:)];
//    self.navigationItem.rightBarButtonItem = self.rightButton;
    
    // disable summary text view editing
    self.summaryView.editable = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadView];
}


/*
 Update outlets according to data
 */

- (void)reloadView
{
    // hide button if there is no data (for initial displaying on iPad splitview)
    if (self.data) {
        self.shareButton.hidden = NO;
        self.appStoreButton.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.rightButton;
        [self.welcomeImageView removeFromSuperview];
    } else {
        self.shareButton.hidden = YES;
        self.appStoreButton.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        
        UIImage *welcomeImage = [UIImage imageNamed:@"Welcome.png"];
        self.welcomeImageView = [[UIImageView alloc]initWithImage:welcomeImage];
        self.welcomeImageView.center = CGPointMake(self.view.frame.size.width / 2.0,
                                                   self.view.frame.size.height / 2.0);
        [self.view addSubview:self.welcomeImageView];
        
    }
    
    self.title = @"Detail";
    self.isFav = [self isFavorited];
    self.navigationItem.rightBarButtonItem.title = self.isFav ? @"Unfav" : @"Fav";
    
    // load icon image
    NSURL *imageURL = [NSURL URLWithString:[self.data[@"im:image"] lastObject][@"label"]];
    if (imageURL) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    // set title / titleLabel
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.title = self.data[@"im:name"][@"label"];
    } else {
        self.titleLabel.text = self.data[@"im:name"][@"label"];
    }
    
    // set other labels
    self.categoryLabel.text = self.data[@"category"][@"attributes"][@"label"];
    self.artistLabel.text = self.data[@"im:artist"][@"label"];
    self.priceLabel.text = self.data[@"im:price"][@"label"];
    self.releaseDateLabel.text = self.data[@"im:releaseDate"][@"attributes"][@"label"];
    self.summaryView.text = self.data[@"summary"][@"label"];
    
    //[self autolayout];
}


// autolayout programmatically if necessary
//- (void)autolayout
//{
//    NSLayoutConstraint *rightContraint = [NSLayoutConstraint constraintWithItem:self.summaryView
//                                                                      attribute:NSLayoutAttributeRight
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:self.view
//                                                                      attribute:NSLayoutAttributeRight
//                                                                     multiplier:1.0
//                                                                       constant:-20.0];
//    [self.view addConstraint:rightContraint];
//}


#pragma mark - Fav Button Actions
- (void)favButtonPressed:(id)sender{
    
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    
    if (self.isFav) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"App" inManagedObjectContext:context];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", self.data[@"id"][@"attributes"][@"im:id"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        // should mutiple error happen: delete them all
        for (NSManagedObject *obj in results) {
            [context deleteObject:obj];
        }
        
        [manager save];
        self.isFav = NO;
        self.navigationItem.rightBarButtonItem.title = @"Fav";
        
    } else {
        App *app = [NSEntityDescription insertNewObjectForEntityForName:@"App"
                                                     inManagedObjectContext:context];
        
        [app setValue:self.data[@"id"][@"attributes"][@"im:id"] forKey:@"id"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        if (!jsonData) {
            NSLog(@"Convert JSON Data error: %@", error);
        } else {
            [app setValue:jsonData forKey:@"data"];
        }

        [manager save];
        
        self.isFav = YES;
        self.navigationItem.rightBarButtonItem.title = @"Unfav";
    }
    
    // reload fav table view if on ipad
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self reloadFavTableView];
    }
    
}

- (void)reloadFavTableView{
    id masterVC = self.splitViewController.viewControllers.firstObject;
    if ([masterVC isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabbarVC = (UITabBarController *) masterVC;
        if(tabbarVC.selectedIndex == 1 && [[tabbarVC.viewControllers lastObject] isKindOfClass:[UINavigationController class]]){
            
            UINavigationController *naviController = (UINavigationController *) [tabbarVC.viewControllers lastObject] ;
            id tableVC = [naviController.viewControllers lastObject];
            if ([tableVC isKindOfClass:[TGFavAppTableViewController class]]) {
                
                TGFavAppTableViewController * favTVC = (TGFavAppTableViewController *)tableVC;
                [favTVC viewWillAppear:YES];
            }
        }
    }
}

- (BOOL)isFavorited
{
    FavDataManager *manager = [FavDataManager sharedInstance];
    NSManagedObjectContext *context = [manager mainObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"App" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", self.data[@"id"][@"attributes"][@"im:id"]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if ([results count] >= 1) {
        if ([results count] > 1){
            NSLog(@"Waring: found duplicate fav records");
        }
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - app store button actions
// does not work on ios simulator due to forbidden service
- (IBAction)itunesButtonPressed:(id)sender {
    NSString *urlString = self.data[@"link"][@"attributes"][@"href"];
    NSLog(@"%@",urlString);
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@"https://" withString:@"itms-apps://"];
    NSLog(@"%@",urlString);
    
    NSURL *itunesURL = [NSURL URLWithString:urlString];
    
    if (itunesURL) {
        [[UIApplication sharedApplication] openURL:itunesURL];
    }
                                                                              
    
}

#pragma mark - share button actions
- (IBAction)shareButtonPressed:(id)sender {
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Share on Facebook",
                            @"Share on Twitter",
                            @"Share via E-mail",
                            @"Copy URL",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (popup.tag == 1) {
        switch (buttonIndex) {
            case 0:
                [self shareToFacebook];
                break;
            case 1:
                [self shareToTwitter];
                break;
            case 2:
                [self shareToEmail];
                break;
            case 3:
                if (self.data[@"id"][@"label"]) {
                    [[UIPasteboard generalPasteboard] setString:self.data[@"id"][@"label"]];
                }
                break;
            default:
                break;
        }
    }
    
}

- (void)shareToFacebook{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *status = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [status setInitialText:@"Just found this awesome app on app store!"];
        
        [status addURL:[NSURL URLWithString:self.data[@"id"][@"label"]]];
        
        [self presentViewController:status animated:YES completion:Nil];
    } else {
        // pretend to be thinking
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Service inavailable"
                                                                message:@"Check Facebook Access in Settings"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView show];
        });    }
    
}

- (void)shareToTwitter{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:@"Just found this awesome app on app store!"];
        
        [tweet addURL:[NSURL URLWithString:self.data[@"id"][@"label"]]];
        
        [self presentViewController:tweet animated:YES completion:nil];
    } else {
        // pretend to be thinking
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Service inavailable"
                                                                message:@"Check Twitter Access in Settings"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView show];
        });
        
    }
    
}

- (void)shareToEmail{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        
        NSString *subject = @"Check out this awesome app!";
        NSString *messageBody = self.data[@"id"][@"label"];
        
        mc.mailComposeDelegate = self;
        
        [mc setSubject:subject];
        [mc setMessageBody:messageBody isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        // pretend to be thinking
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Service inavailable"
                                                                message:@"Check Mail Access in Settings"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView show];
        });
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UISplitViewControllerDelegate
- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
