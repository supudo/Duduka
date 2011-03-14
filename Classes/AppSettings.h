//
//  AppSettings.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface AppSettings : NSObject {
	BOOL InDebug, HasAutoRefreshFinished;
	NSString *AutoRefreshInterval, *AppVersion;
}

@property BOOL InDebug, HasAutoRefreshFinished;
@property (nonatomic, retain) NSString *AutoRefreshInterval, *AppVersion;

- (void) LogThis: (NSString *)log;
- (BOOL) connectedToInternet;

+ (AppSettings *)sharedAppSettings;

@end
