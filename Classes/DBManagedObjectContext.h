//
//  DBManagedObjectContext.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManagedObjectContext : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DBManagedObjectContext *)sharedDBManagedObjectContext;

- (NSManagedObject *)getEntity:(NSString *)entityName predicateString:(NSString *)predicateString;
- (NSManagedObject *)getEntity:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSArray *)getEntities:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSArray *)getEntities:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)getEntities:(NSString *)entityName;
- (BOOL)deleteAllObjects:(NSString *)entityName;
- (BOOL)deleteObjects:(NSString *)entityName predicate: (NSPredicate *)predicate;
- (BOOL)wipeoutData;

- (NSString *)applicationDocumentsDirectory;

@end
