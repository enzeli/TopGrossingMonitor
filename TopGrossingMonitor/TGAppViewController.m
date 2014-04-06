//
//  TGAppViewController.m
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/4/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "TGAppViewController.h"
#import "FavDataManager.h"
#import "App.h"
@import CoreData;
@import Social;

@interface TGAppViewController ()

@property (assign) BOOL isFav;

@end

@implementation TGAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.data[@"im:name"][@"label"];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(favButtonPressed:)];

    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isFav = [self isFavorited];
    self.navigationItem.rightBarButtonItem.title = self.isFav ? @"Unfav" : @"Fav";
}

-(void)favButtonPressed:(id)sender{
    
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
        
        NSLog(@"Deleted fav");
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

        NSLog(@"Added fav");
        
        self.isFav = YES;
        self.navigationItem.rightBarButtonItem.title =@"Unfav";
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
            // TODO: deal with it later
            NSLog(@"Waring: found duplicate fav records");
        }
        return YES;
    } else {
        return NO;
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
                [[UIPasteboard generalPasteboard] setString:self.data[@"id"][@"label"]];
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
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
