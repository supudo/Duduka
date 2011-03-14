//
//  FeedItemView.h
//  Duduka
//
//  Created by Sergey Petrov on 8/31/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "dbFeedData.h"
#import "LoadingView.h"
#import "SNInstapaper.h"

@interface FeedItemView : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, SNInstapaperDelegate> {
	dbFeedData *feedDataObject;
	UIScrollView *viewScroll;
	UIWebView *wvContent;
	UIView *feedActions;
	NSFetchedResultsController *fetchedResultsController;
	NSIndexPath *indexPath;
	LoadingView *loadingView;
}

@property (nonatomic, retain) dbFeedData *feedDataObject;
@property (nonatomic, retain) IBOutlet UIScrollView *viewScroll;
@property (nonatomic, retain) IBOutlet UIWebView *wvContent;
@property (nonatomic, retain) UIView *feedActions;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) LoadingView *feedActionsView;

- (void)setRightNavItems;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;

@end
