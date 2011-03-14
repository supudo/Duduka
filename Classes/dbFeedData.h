//
//  dbFeedData.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <CoreData/CoreData.h>

@class dbFeed;

@interface dbFeedData :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * LocalCategories;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSString * Content;
@property (nonatomic, retain) NSString * URLComments;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSNumber * IsRead;
@property (nonatomic, retain) dbFeed * feed;

@end



