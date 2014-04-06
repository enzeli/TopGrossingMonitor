//
//  FavDataManager.m
//  GoPlacesPro
//
//  Created by Enze Li on 3/17/14.
//  Copyright (c) 2014 Enze Li. All rights reserved.
//

#import "FavDataManager.h"
@import CoreData;

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface FavDataManager ()

@property (nonatomic, assign) BOOL updated;

- (NSString*)sharedDocumentsPath;

@end

@implementation FavDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

NSString * const kDataManagerBundleName = @"GoPlacesPro";
NSString * const kDataManagerModelName = @"Model";
NSString * const kDataManagerSQLiteName = @"GoPlacesPro.sqlite";

+ (FavDataManager*)sharedInstance {
	static dispatch_once_t pred;
	static FavDataManager *sharedInstance = nil;
    
    // create singleton
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    
	return sharedInstance;
}

- (BOOL)hasUpdated
{
    if (self.updated){
        self.updated = NO;
        return YES;
    }
    else
        return NO;
}

- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
//	if (kDataManagerBundleName) {
//		NSString *bundlePath = [bundle pathForResource:kDataManagerBundleName ofType:@"bundle"];
//        NSLog(@"bundle path: %@", bundlePath);
//        NSLog(@"Bundle name: %@",[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] description]);
//        
//		bundle = [NSBundle bundleWithPath:bundlePath];
//	}
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
//    NSLog(@"model path: %@", modelPath);
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainObjectContext;
}

- (BOOL)save {
    
	if (![self.mainObjectContext hasChanges])
		return YES;
    
    self.updated = YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
//		[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
//                                                            object:error];
		return NO;
	}
    
//	[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
//    NSLog(@"SharedDocumentsPath: %@", SharedDocumentsPath);
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

@end
