//
//  FeedData.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "FeedData.h"
#import "DBManagedObjectContext.h"
#import "FeedItemView.h"
#import "BlackAlertView.h"
#import "UINavigationItemCleanBG.h"

static NSString *kCellIdentifier = @"MyIdentifier";

@implementation FeedData

@synthesize fetchedResultsController, feedObject, searchBar, rssParser, loadingActionSheet, searchKeyword;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.loadingActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Common.Loading", @"") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self setRightNavItems];
	[self searchFeeds:nil];

	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];

	if (self.feedObject != nil)
		self.title = self.feedObject.Title;

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Feed data fetch error %@, %@", error, [error userInfo]]];
		abort();
	}

	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.searchBar.hidden = NO;
}

- (void)setRightNavItems {
	SilentToolbar *toolbar = [[SilentToolbar alloc] initWithFrame:CGRectMake(0, 0, 88, 44.4)];
	[toolbar setBarStyle: UIBarStyleBlackTranslucent];
	[toolbar setBackgroundColor:[UIColor clearColor]];
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];

	UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchFeeds:)];
	btnSearch.style = UIBarButtonItemStyleBordered;
	[buttons addObject:btnSearch];
	[btnSearch release];

	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:spacer];
	[spacer release];

	UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
	btnRefresh.style = UIBarButtonItemStyleBordered;
	[buttons addObject:btnRefresh];
	[btnRefresh release];
	
	[toolbar setItems:buttons animated:NO];
	[buttons release];

	UIBarButtonItem *rightBarItems = [[UIBarButtonItem alloc]  initWithCustomView:toolbar];
	rightBarItems.style = UIBarStyleBlackTranslucent;
	self.navigationItem.rightBarButtonItem = rightBarItems;
	[rightBarItems release];
	[toolbar release];
}

- (void)searchFeeds:(id)sender {
	if (self.searchBar.hidden) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.75];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.searchBar cache:YES];
		self.tableView.tableHeaderView = self.searchBar;
		self.searchBar.hidden = NO;
		[self.searchBar becomeFirstResponder];
		[UIView commitAnimations];
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.75];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.searchBar cache:YES];
		self.searchBar.hidden = YES;
		[self.searchBar resignFirstResponder];
		self.tableView.tableHeaderView = nil;
		[self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:NO];
		[UIView commitAnimations];
	}
}

- (void)refreshFeed:(id)sender {
	[self showLoadingSheet];
	if (self.rssParser == nil)
		self.rssParser = [[RssParser alloc] init];
	[self.rssParser setDelegate:self];
	[self.rssParser startParse:self.feedObject.URL category:self.feedObject.category];
}

- (void)parserFinished:(id)sender {
	[self hideLoadingSheet];
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Feed data fetch error %@, %@", error, [error userInfo]]];
		abort();
	}
	[self.tableView reloadData];
}

- (void)parserProgress:(id)sender progress:(NSString *)subProgress {
	self.loadingActionSheet.title = subProgress;
}

- (void)parserError:(id)sender error:(NSString *)errorMessage {
	[self hideLoadingSheet];
	[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
	BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Retry", nil];
	alert.tag = 90;
	[alert show];
	[alert release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	self.navigationItem.title = [NSString stringWithFormat:@"%@ (%i)", self.feedObject.Title, [sectionInfo numberOfObjects]];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	dbFeedData *feedObj = [fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
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

	if ([feedObj.IsRead boolValue])
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
	else
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
	cell.textLabel.text = feedObj.Title;

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMMM dd, yyyy HH:ss"];
	cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
	cell.detailTextLabel.text = ((feedObj.Date == nil) ? @"" : [format stringFromDate:feedObj.Date]);
	cell.detailTextLabel.textColor = [UIColor darkTextColor];
	[format release];

	cell.imageView.image = [UIImage imageWithData:self.feedObject.Favicon];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	dbFeedData *feedObj = (dbFeedData *)[fetchedResultsController objectAtIndexPath:indexPath];
	FeedItemView *tvc = [[FeedItemView alloc] initWithNibName:@"FeedItemView" bundle:nil];
	tvc.feedDataObject = feedObj;
	tvc.fetchedResultsController = fetchedResultsController;
	tvc.indexPath = indexPath;
	[[self navigationController] pushViewController:tvc animated:YES];
	[tvc release];
}

- (NSFetchedResultsController *)fetchedResultsController {
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedData" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
        [fetchRequest setEntity:entity];

        NSSortDescriptor *sortDescriptorIsRead = [[NSSortDescriptor alloc] initWithKey:@"IsRead" ascending:YES];
        NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorIsRead, sortDescriptorDate, nil];

        [fetchRequest setSortDescriptors:sortDescriptors];

		NSPredicate *predicate;
		if ([self.searchKeyword isEqualToString:@""] || self.searchKeyword == nil)
			predicate = [NSPredicate predicateWithFormat:@"feed = %@", self.feedObject];
		else
			predicate = [NSPredicate predicateWithFormat:@"feed = %@ AND Title CONTAINS[cd] %@", self.feedObject, self.searchKeyword];
		[fetchRequest setPredicate:predicate];

        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[dbManagedObjectContext managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;

        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptorIsRead release];
        [sortDescriptorDate release];
        [sortDescriptors release];
    }
	return fetchedResultsController;
}

- (void) showLoadingSheet {
	self.loadingActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[self.loadingActionSheet showInView:self.view];
}

- (void) hideLoadingSheet {
	[self.loadingActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[self setRightNavItems];
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchKeyword = searchText;
	self.fetchedResultsController = nil;
	[self.searchDisplayController setActive:YES];
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Feed data search error %@, %@", error, [error userInfo]]];
		abort();
	}
	[self.tableView reloadData];
	[self.searchDisplayController setActive:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[loadingActionSheet release];
	[feedObject release];
	[fetchedResultsController release];
	[rssParser release];
	[searchBar release];
	[searchKeyword release];
    [super dealloc];
}

@end
