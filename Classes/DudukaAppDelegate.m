//
//  DudukaAppDelegate.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright n/a 2010. All rights reserved.
//

#import "DudukaAppDelegate.h"
#import "Loading.h"
#import "FeedWorker.h"

DudukaAppDelegate *appDelegate;

@implementation DudukaAppDelegate

@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	appDelegate = self;
	
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
    Loading *lvc = [[Loading alloc] initWithNibName:@"Loading" bundle:nil];
    [self.tabBarController presentModalViewController:lvc animated:NO];
    [lvc release];

    return YES;
}

- (void)loadingFinished {
    [self.tabBarController dismissModalViewControllerAnimated:NO];
}

- (void)startBackgroundWorkers {
	[NSTimer scheduledTimerWithTimeInterval:[[AppSettings sharedAppSettings].AutoRefreshInterval doubleValue] target:self selector:@selector(doAutoRefresh) userInfo:nil repeats:YES];
}

- (void)doAutoRefresh {
	if ([[AppSettings sharedAppSettings].AutoRefreshInterval doubleValue] > 0 && [AppSettings sharedAppSettings].HasAutoRefreshFinished) {
		[AppSettings sharedAppSettings].HasAutoRefreshFinished = FALSE;		
		[NSThread detachNewThreadSelector:@selector(startThreadRefreshFeeds) toTarget:self withObject:nil];
		NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
		[format setDateFormat:@"HH:mm:ss"];
		[[AppSettings sharedAppSettings] LogThis:[NSString stringWithFormat:@"++ threadRefreshFeeds called @ %@", [format stringFromDate:[NSDate date]]]];
	}
}

- (void)startThreadRefreshFeeds {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	FeedWorker *fw = [[FeedWorker alloc] init];
	if ([fw refreshAllFeeds])
		[AppSettings sharedAppSettings].HasAutoRefreshFinished = TRUE;
	[pool release];
}

- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}

@end
