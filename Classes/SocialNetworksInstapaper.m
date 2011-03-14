//
//  SocialNetworksInstapaper.m
//  Duduka
//
//  Created by Sergey Petrov on 9/8/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "SocialNetworksInstapaper.h"
#import "DBManagedObjectContext.h"
#import "dbSettings.h"

@implementation SocialNetworksInstapaper

@synthesize lblUsername, lblPassword, txtUsername, txtPassword;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Settings.SN.Instapaper", @"");
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings.Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveSetting:)];
	self.lblUsername.text = NSLocalizedString(@"Common.Username", @"");
	self.lblPassword.text = NSLocalizedString(@"Common.Password", @"");
}

- (void)viewWillAppear:(BOOL)animated {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
	dbSettings *ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"InstapaperUsername"]];
	if (ent != nil)
		self.txtUsername.text = ent.SValue;
	
	ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"InstapaperPassword"]];
	if (ent != nil)
		self.txtPassword.text = ent.SValue;

	[self.txtUsername becomeFirstResponder];
}

- (void)saveSetting:(id)sender {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];

	dbSettings *ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"InstapaperUsername"]];
	if (ent == nil) {
		ent = (dbSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		[ent setSName:@"InstapaperUsername"];
	}
	[ent setSValue:self.txtUsername.text];

	ent = (dbSettings *)[dbManagedObjectContext getEntity:@"Settings" predicate:[NSPredicate predicateWithFormat:@"SName = %@", @"InstapaperPassword"]];
	if (ent == nil) {
		ent = (dbSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		[ent setSName:@"InstapaperPassword"];
	}
	[ent setSValue:self.txtPassword.text];

	NSError *error = nil;
	if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Settings Save: %@!", [error userInfo]]];
		abort();
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[lblUsername release];
	[lblPassword release];
	[txtUsername release];
	[txtPassword release];
    [super dealloc];
}

@end
