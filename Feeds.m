//
//  Feeds.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "Feeds.h"
#import "DBManagedObjectContext.h"
#import "FeedsAddNew.h"
#import "FeedData.h"
#import "UINavigationItemCleanBG.h"

static NSString *kCellIdentifier = @"MyIdentifier";

@implementation Feeds

@synthesize fetchedResultsController, parentCategory;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFeed:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(backToCategories:)];

	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	if (self.parentCategory == nil)
		self.title = NSLocalizedString(@"Feeds.NavTitle", @"");
	else
		self.title = [self.parentCategory valueForKey:@"Title"];
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]]];
		abort();
	}
	
	[self.tableView reloadData];
}

- (void)addFeed:(id)sender {
	FeedsAddNew *tvc = [[FeedsAddNew alloc] initWithNibName:@"FeedsAddNew" bundle:nil];
	tvc.parentCategory = self.parentCategory;
	[[self navigationController] pushViewController:tvc animated:YES];
	[tvc release];
}

- (void)backToCategories:(id)sender {
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	if (self.parentCategory == nil)
		self.title = [NSString stringWithFormat:@"%@ (%i)", NSLocalizedString(@"Feeds.NavTitle", @""), [sectionInfo numberOfObjects]];
	else
		self.title = [NSString stringWithFormat:@"%@ (%i)", [self.parentCategory valueForKey:@"Title"], [sectionInfo numberOfObjects]];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	dbFeed *feedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
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

	cell.textLabel.text = feedObject.Title;
	cell.imageView.image = [UIImage imageWithData:feedObject.Favicon];

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMMM dd, yyyy HH:ss"];
	cell.detailTextLabel.text = ((feedObject.LastUpdateDate == nil) ? @"" : [format stringFromDate:feedObject.LastUpdateDate]);
	[format release];

	UIButton *fCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	fCount.frame = CGRectMake(2, 2, 30, 20);
	[fCount setEnabled:TRUE];
	[fCount setTitle:[NSString stringWithFormat:@"%i", [feedObject.feedData count]] forState:UIControlStateNormal];
	[fCount.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
	[fCount.titleLabel setTextAlignment:UITextAlignmentCenter];
	[fCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[fCount addTarget:self action:@selector(actionLoadFeed:event:) forControlEvents:UIControlEventTouchUpInside];
	[fCount.titleLabel setAdjustsFontSizeToFitWidth:YES];
	cell.accessoryView = fCount;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	dbFeed *feedObject = (dbFeed *)[fetchedResultsController objectAtIndexPath:indexPath];
	FeedData *tvc = [[FeedData alloc] initWithNibName:@"FeedData" bundle:nil];
	tvc.feedObject = feedObject;
	[[self navigationController] pushViewController:tvc animated:YES];
	[tvc release];
}

- (void)actionLoadFeed:(id)sender event:(id)event {
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
	if (indexPath != nil)
		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (NSFetchedResultsController *)fetchedResultsController {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
        [fetchRequest setEntity:entity];
		
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"LastUpdateDate" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %@", self.parentCategory];
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
