//
//  dbSettings.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <CoreData/CoreData.h>

@class dbFeed;

@interface dbSettings :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * SName;
@property (nonatomic, retain) NSString * SValue;
@property (nonatomic, retain) dbFeed * feed;

@end



