//
//  FeedData.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dbFeed.h"
#import "dbFeedData.h"
#import "RssParser.h"

@interface FeedData : UITableViewController<NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, RssParserDelegate> {
	UIActionSheet *loadingActionSheet;
	NSFetchedResultsController *fetchedResultsController;
	UISearchBar *searchBar;
	dbFeed *feedObject;
	RssParser *rssParser;
	NSString *searchKeyword;
}

@property (nonatomic, retain) UIActionSheet *loadingActionSheet;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) dbFeed *feedObject;
@property (nonatomic, retain) RssParser *rssParser;
@property (nonatomic, retain) NSString *searchKeyword;

- (void)searchFeeds:(id)sender;
- (void)refreshFeed:(id)sender;
- (void)showLoadingSheet;
- (void)hideLoadingSheet;
- (void)setRightNavItems;

@end
