//
//  DBManagedObjectContext.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "DBManagedObjectContext.h"

@implementation DBManagedObjectContext

SYNTHESIZE_SINGLETON_FOR_CLASS(DBManagedObjectContext);

- (NSManagedObject *)getEntity:(NSString *)entityName predicateString:(NSString *)predicateString {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([items count] > 0)
		return [items objectAtIndex:0];
	else
		return nil;
}

- (NSManagedObject *)getEntity:(NSString *)entityName predicate:(NSPredicate *)predicate {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([items count] > 0)
		return [items objectAtIndex:0];
	else
		return nil;
}

- (NSArray *)getEntities:(NSString *)entityName predicate:(NSPredicate *)predicate {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([items count] > 0)
		return items;
	else
		return nil;
}

- (NSArray *)getEntities:(NSString *)entityName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([items count] > 0)
		return items;
	else
		return nil;
}

- (NSArray *)getEntities:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors: (NSArray *)sortDescriptors {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors: sortDescriptors];
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if ([items count] > 0)
		return items;
	else
		return nil;
}

- (BOOL) deleteAllObjects: (NSString *)entityName  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
    for (NSManagedObject *managedObject in items)
        [managedObjectContext deleteObject:managedObject];

    if (![managedObjectContext save:&error])
		return FALSE;
	return TRUE;
}

- (BOOL) deleteObjects: (NSString *)entityName predicate: (NSPredicate *)predicate  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];

	for (NSManagedObject *managedObject in items)
		[managedObjectContext deleteObject:managedObject];

    if (![managedObjectContext save:&error])
		return FALSE;
	return TRUE;
}

- (BOOL) wipeoutData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    for (NSManagedObject *managedObject in items)
        [managedObjectContext deleteObject:managedObject];
    if (![managedObjectContext save:&error])
		return FALSE;
	return TRUE;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[super dealloc];
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
	if (managedObjectContext != nil)
		return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [NSManagedObjectContext new];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
	return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil)
		return managedObjectModel;
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Duduka.sqlite"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Duduka" ofType:@"sqlite"];
		if (defaultStorePath)
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"DBManagedContext: %@!", [error userInfo]]];
		abort();
    }    
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
