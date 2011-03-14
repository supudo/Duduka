//
//  CategoriesAddNew.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "CategoriesAddNew.h"
#import "DBManagedObjectContext.h"
#import "BlackAlertView.h"

@implementation CategoriesAddNew

@synthesize parentCategory, lblParentLabel, lblParentTitle, txtCategory;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = NSLocalizedString(@"CategoriesAddNew.NavTitle", @"");
	self.lblParentLabel.text = NSLocalizedString(@"CategoriesAddNew.ParentCategory", @"");
	if (self.parentCategory == nil)
		self.lblParentTitle.text = NSLocalizedString(@"CategoriesAddNew.Root", @"");
	else
		self.lblParentTitle.text = self.parentCategory.Title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CategoriesAddNew.Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveCategory:)];
	[self.txtCategory becomeFirstResponder];
}

- (void)saveCategory:(id)sender {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	dbCategory *cat = (dbCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
	cat.Title = self.txtCategory.text;

	NSError *error = nil;
	if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Last Sync (VSync): %@!", [error userInfo]]];
		abort();
	}

	[self.navigationController popViewControllerAnimated:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[parentCategory release];
	[lblParentLabel release];
	[lblParentTitle release];
	[txtCategory release];
    [super dealloc];
}

@end
