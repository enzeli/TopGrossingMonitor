//
//  FavDataManager.h
//  GoPlacesPro
//
//  Created by Enze Li on 3/17/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface FavDataManager : NSObject

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FavDataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;
- (BOOL)hasUpdated;

@end
