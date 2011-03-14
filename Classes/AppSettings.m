//
//  AppSettings.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "AppSettings.h"
#import "Reachability.h"

@implementation AppSettings

SYNTHESIZE_SINGLETON_FOR_CLASS(AppSettings);

@synthesize InDebug, HasAutoRefreshFinished;
@synthesize AutoRefreshInterval, AppVersion;

- (void) LogThis: (NSString *)log {
	if (self.InDebug)
		NSLog(@"[_____ DUDUKA-DEBUG] : %@", log);
}

- (BOOL)connectedToInternet {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];	
	BOOL result = FALSE;
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN)
	    result = TRUE;
	return result;
}

- (id) init {
	if (self = [super init]) {
		self.InDebug = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"DDInDebug"] boolValue];
		self.HasAutoRefreshFinished = TRUE;
		self.AutoRefreshInterval = @"0";
		self.AppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	}
	return self;
}

@end
