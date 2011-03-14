//
//  Loading.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "Loading.h"
#import "DBManagedObjectContext.h"

@implementation Loading

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[NSThread detachNewThreadSelector:@selector(doLoading) toTarget:self withObject:nil];
}

- (void)doLoading {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	NSArray *settings = [dbManagedObjectContext getEntities:@"Settings"];
	for (NSManagedObject *ent in settings) {
		if ([[ent valueForKey:@"SName"] isEqualToString:@"AutoRefreshInterval"])
			[AppSettings sharedAppSettings].AutoRefreshInterval = [ent valueForKey:@"SValue"];
	}

	[self performSelectorOnMainThread: @selector(doLoadingFinished) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void)doLoadingFinished {
	[appDelegate startBackgroundWorkers];
	[appDelegate loadingFinished];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

@end
