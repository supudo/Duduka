//
//  SNInstapaper.m
//  Duduka
//
//  Created by Sergey Petrov on 9/8/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "SNInstapaper.h"
#import "DBManagedObjectContext.h"
#import "URLReader.h"

@implementation SNInstapaper

@synthesize delegate;

- (void)send:(dbFeedData *)feed {
	URLReader *urlReader = [[URLReader alloc] init];

	NSString *ipUsername, *ipPassword;
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	NSArray *settings = [dbManagedObjectContext getEntities:@"Settings"];
	for (NSManagedObject *ent in settings) {
		if ([[ent valueForKey:@"SName"] isEqualToString:@"InstapaperUsername"])
			ipUsername = [ent valueForKey:@"SValue"];
		if ([[ent valueForKey:@"SName"] isEqualToString:@"InstapaperPassword"])
			ipPassword = [ent valueForKey:@"SValue"];
	}

	NSMutableString *ipURL = [[NSMutableString alloc] init];
	[ipURL setString:@"https://www.instapaper.com/api/add?"];
	[ipURL appendFormat:@"url=%@", [urlReader urlCryptedEncode:feed.URL]];
	[ipURL appendFormat:@"&title=%@", [urlReader urlCryptedEncode:feed.Title]];
	[ipURL appendFormat:@"&username=%@", ipUsername];
	[ipURL appendFormat:@"&password=%@", ipPassword];

	[[AppSettings sharedAppSettings] LogThis:[NSString stringWithFormat:@"Instapaper request = %@", ipURL]];
	NSString *response = [urlReader getFromURL:ipURL postData:@""];
	[[AppSettings sharedAppSettings] LogThis:[NSString stringWithFormat:@"Instapaper response = %@", response]];
	[urlReader release];

	if ([response isEqualToString:@"201"]) {
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(InstapaperSubmitSuccess:)])
			[delegate InstapaperSubmitSuccess:self];
	}
	else {
		NSString *msg = NSLocalizedString(@"Common.Error", @"");
		if ([response isEqualToString:@"400"])
			msg = NSLocalizedString(@"Common.Error400", @"");
		if ([response isEqualToString:@"403"])
			msg = NSLocalizedString(@"Common.Error403", @"");
		if ([response isEqualToString:@"500"])
			msg = NSLocalizedString(@"Common.Error500", @"");
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(InstapaperSubmitFailed:errorMessage:)])
			[delegate InstapaperSubmitFailed:self errorMessage:msg];
	}
}

@end
