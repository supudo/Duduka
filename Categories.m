//
//  Categories.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "Categories.h"
#import "DBManagedObjectContext.h"
#import "Feeds.h"
#import "CategoriesAddNew.h"
#import "BlackAlertView.h"

static NSString *kCellIdentifier = @"MyIdentifier";

@implementation Categories

@synthesize fetchedResultsController, parentCategory;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategory:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCategories:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]]];
		abort();
	}

	if (self.parentCategory == nil)
		self.navigationItem.title = NSLocalizedString(@"Categories.NavTitle", @"");
	else
		self.navigationItem.title = [self.parentCategory valueForKey:@"Title"];
	
	[self.tableView reloadData];
}

- (void)addCategory:(id)sender {
	CategoriesAddNew *tvc = [[CategoriesAddNew alloc] initWithNibName:@"CategoriesAddNew" bundle:nil];
	tvc.parentCategory = self.parentCategory;
	[[self navigationController] pushViewController:tvc animated:YES];
	[tvc release];
}

- (void)editCategories:(id)sender {
	self.tableView.editing = YES;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCategories:)];
}

- (void)saveCategories:(id)sender {
	self.tableView.editing = NO;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCategories:)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	if (self.parentCategory == nil)
		self.navigationItem.title = [NSString stringWithFormat:@"%@ (%i)", NSLocalizedString(@"Categories.NavTitle", @""), [sectionInfo numberOfObjects]];
	else
		self.navigationItem.title = [NSString stringWithFormat:@"%@ (%i)", [self.parentCategory valueForKey:@"Title"], [sectionInfo numberOfObjects]];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	dbCategory *categoryObject = [fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	UIView *bgView = [[UIView alloc] init];
	bgView.backgroundColor = [UIColor whiteColor];
	if (indexPath.row % 2 == 0)
		bgView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
	cell.textLabel.backgroundColor = bgView.backgroundColor;
	cell.detailTextLabel.backgroundColor = bgView.backgroundColor;
	cell.backgroundView = bgView;
	[bgView release];

	cell.textLabel.text = categoryObject.Title;
	
	UIButton *fCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	fCount.frame = CGRectMake(2, 2, 30, 20);
	[fCount setEnabled:TRUE];
	[fCount setTitle:[NSString stringWithFormat:@"%i", [categoryObject.feeds count]] forState:UIControlStateNormal];
	[fCount.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
	[fCount.titleLabel setTextAlignment:UITextAlignmentCenter];
	[fCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[fCount addTarget:self action:@selector(actionLoadFeed:event:) forControlEvents:UIControlEventTouchUpInside];
	[fCount.titleLabel setAdjustsFontSizeToFitWidth:YES];
	cell.accessoryView = fCount;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	dbCategory *categoryObject = [fetchedResultsController objectAtIndexPath:indexPath];
	if ([categoryObject valueForKey:@"parentCategory"] == nil) {
		Feeds *tvc = [[Feeds alloc] initWithNibName:@"Feeds" bundle:nil];
		tvc.parentCategory = categoryObject;
		[[self navigationController] pushViewController:tvc animated:YES];
		[tvc release];
	}
	else {
		Categories *tvc = [[Categories alloc] initWithNibName:@"Categories" bundle:nil];
		tvc.parentCategory = categoryObject;
		[[self navigationController] pushViewController:tvc animated:YES];
		[tvc release];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	dbCategory *categoryObject = [fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[dbManagedObjectContext managedObjectContext] deleteObject:categoryObject];
		NSError *error = nil;
		if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
			[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Categories save error: %@!", [error userInfo]]];

			[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
			BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Common.Error", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
		error = nil;
		if (![fetchedResultsController performFetch:&error]) {
			[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Categories get error: %@!", [error userInfo]]];
			
			[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
			BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Common.Error", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}

		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}

- (NSFetchedResultsController *)fetchedResultsController {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentCategory = %@", [self.parentCategory valueForKey:@"category"]];
		[fetchRequest setPredicate:predicate];
	
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[dbManagedObjectContext managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
		
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	return fetchedResultsController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[fetchedResultsController release];
	[parentCategory release];
    [super dealloc];
}

@end
