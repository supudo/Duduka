//
//  AutoRefreshInterval.m
//  Duduka
//
//  Created by Sergey Petrov on 9/2/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "AutoRefreshInterval.h"
#import "DBManagedObjectContext.h"
#import "dbSettings.h"

@implementation AutoRefreshInterval

@synthesize txtInterval;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings.Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveSetting:)];
}

- (void)viewWillAppear:(BOOL)animated {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
	dbSettings *ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"AutoRefreshInterval"]];
	if (ent == nil) {
		ent = (dbSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		[ent setSName:@"WebServicesURL"];
		[ent setSValue:[AppSettings sharedAppSettings].AutoRefreshInterval];
		
		NSError *error = nil;
		if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
			[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Settings Save: %@!", [error userInfo]]];
			abort();
		}
	}
	self.txtInterval.text = [ent valueForKey:@"SValue"];
	[self.txtInterval becomeFirstResponder];
}

- (void)saveSetting:(id)sender {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
	dbSettings *ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"AutoRefreshInterval"]];
	if (ent == nil) {
		ent = (dbSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		[ent setSName:@"AutoRefreshInterval"];
	}
	[ent setSValue:self.txtInterval.text];
	[AppSettings sharedAppSettings].AutoRefreshInterval = self.txtInterval.text;
	
	NSError *error = nil;
	if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Settings Save: %@!", [error userInfo]]];
		abort();
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[txtInterval release];
    [super dealloc];
}

@end
