//
//  FeedWorker.m
//  Duduka
//
//  Created by Sergey Petrov on 9/2/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "FeedWorker.h"
#import "DBManagedObjectContext.h"
#import "RssParser.h"

@implementation FeedWorker

- (BOOL)refreshAllFeeds {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
    NSError *error = nil;
	RssParser *rssParser = [[RssParser alloc] init];
	NSArray *categories = [dbManagedObjectContext getEntities:@"Feed"];
	for (NSManagedObject *ent in categories) {
		[rssParser startParse:[ent valueForKey:@"URL"] category:[ent valueForKey:@"category"]];
		[ent setValue:[NSDate date] forKey:@"LastRefreshDate"];
		[[AppSettings sharedAppSettings] LogThis:[NSString stringWithFormat:@"Feed refreshed %@", [ent valueForKey:@"URL"]]];
	}
	if (![[dbManagedObjectContext managedObjectContext] save:&error])
		return FALSE;
	return TRUE;
}

@end
