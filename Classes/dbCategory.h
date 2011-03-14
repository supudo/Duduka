//
//  dbCategory.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <CoreData/CoreData.h>

@class dbFeed;

@interface dbCategory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet* feeds;
@property (nonatomic, retain) dbCategory * parentCategory;

@end


@interface dbCategory (CoreDataGeneratedAccessors)
- (void)addFeedsObject:(dbFeed *)value;
- (void)removeFeedsObject:(dbFeed *)value;
- (void)addFeeds:(NSSet *)value;
- (void)removeFeeds:(NSSet *)value;

@end

