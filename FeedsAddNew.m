//
//  FeedsAddNew.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "FeedsAddNew.h"
#import "DBManagedObjectContext.h"
#import "BlackAlertView.h"

@implementation FeedsAddNew

@synthesize loadingActionSheet, parentCategory, lblParentLabel, lblParentTitle, lblProgress, txtFeedURL, rssParser;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.loadingActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Common.Loading", @"") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = NSLocalizedString(@"FeedsAddNew.NavTitle", @"");
	self.lblParentLabel.text = NSLocalizedString(@"FeedsAddNew.ParentCategory", @"");
	self.lblProgress.text = @"";
	self.lblParentTitle.text = self.parentCategory.Title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FeedsAddNew.Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveFeed:)];
	
	if ([AppSettings sharedAppSettings].InDebug) {
		//self.txtFeedURL.text = @"http://www.kldn.net/?feed=rss2";
		self.txtFeedURL.text = @"http://feeds.feedburner.com/eenk?format=xml";
	}
	[self.txtFeedURL becomeFirstResponder];
}

- (void)saveFeed:(id)sender {
	[self showLoadingSheet];
	if (self.rssParser == nil)
		self.rssParser = [[RssParser alloc] init];
	[self.rssParser setDelegate:self];
	self.txtFeedURL.enabled = FALSE;
	/*
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	[arr addObject:@"feed://feeds.feedzilla.com/en_us/news_headlines/top-news/art.rss"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/entertainment"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/internet"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/life-style"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/politics"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/sports"];
	[arr addObject:@"http://www.feedzilla.com/rss/top-news/video-games"];
	 */
	[self.rssParser startParse:self.txtFeedURL.text category:self.parentCategory];
}

- (void)parserFinished:(id)sender {
	[self hideLoadingSheet];
	[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
	BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FeedsAddNew.Finished", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	alert.tag = 91;
	[alert show];
	[alert release];
}

- (void)parserProgress:(id)sender progress:(NSString *)subProgress {
	self.lblProgress.text = subProgress;
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

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 90) {
		if (buttonIndex == 1)
			[self saveFeed:nil];
		else
			[self.navigationController popViewControllerAnimated:TRUE];
	}
	else
		[self.navigationController popViewControllerAnimated:TRUE];
}

- (void) showLoadingSheet {
	self.loadingActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[self.loadingActionSheet showFromTabBar:appDelegate.tabBarController.tabBar];
}

- (void) hideLoadingSheet {
	[self.loadingActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[loadingActionSheet release];
	[parentCategory release];
	[lblParentLabel release];
	[lblParentTitle release];
	[lblProgress release];
	[txtFeedURL release];
	[rssParser release];
    [super dealloc];
}

@end
