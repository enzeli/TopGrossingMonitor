//
//  App.h
//  TopGrossingMonitor
//
//  Created by Enze Li on 4/5/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface App : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSData * data;

@end
