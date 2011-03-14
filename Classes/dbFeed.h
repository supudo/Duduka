//
//  dbFeed.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <CoreData/CoreData.h>

@class dbCategory;
@class dbFeedData;
@class dbSettings;

@interface dbFeed :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * Favicon;
@property (nonatomic, retain) NSDate * LastUpdateDate;
@property (nonatomic, retain) NSDate * LastRefreshDate;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) dbCategory * category;
@property (nonatomic, retain) dbSettings * credentials;
@property (nonatomic, retain) NSSet* feedData;

@end


@interface dbFeed (CoreDataGeneratedAccessors)
- (void)addFeedDataObject:(dbFeedData *)value;
- (void)removeFeedDataObject:(dbFeedData *)value;
- (void)addFeedData:(NSSet *)value;
- (void)removeFeedData:(NSSet *)value;

@end

