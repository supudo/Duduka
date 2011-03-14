//
//  FeedItemView.m
//  Duduka
//
//  Created by Sergey Petrov on 8/31/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "FeedItemView.h"
#import "DBManagedObjectContext.h"
#import "dbFeedData.h"
#import "UINavigationItemCleanBG.h"
#import "BlackAlertView.h"

@implementation FeedItemView

#pragma mark -
#pragma mark Variables

@synthesize feedDataObject, viewScroll, wvContent, feedActions, fetchedResultsController, indexPath, feedActionsView;

#pragma mark -
#pragma mark Init

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self setRightNavItems];
	if (self.feedDataObject != nil) {
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"MMM dd, yyyy HH:ss"];
		self.navigationItem.title = ((self.feedDataObject.Date == nil) ? self.feedDataObject.Author : [format stringFromDate:self.feedDataObject.Date]);
		[format release];
		self.navigationItem.title = self.feedDataObject.Author;
	}
	[self.wvContent setDelegate:self];
	NSMutableString *htmlContent = [[NSMutableString alloc] init];
	[htmlContent setString:@""];
	[htmlContent appendFormat:@"%@<br><br><br>", self.feedDataObject.Title];
	[htmlContent appendFormat:@"%@", self.feedDataObject.Content];
	[self.wvContent loadHTMLString:htmlContent baseURL:nil];
	[htmlContent release];
	
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	dbFeedData *ent = (dbFeedData *)[dbManagedObjectContext getEntity:@"FeedData" predicate:[NSPredicate predicateWithFormat:@"URL = %@", self.feedDataObject.URL]];
	if (ent != nil) {
		[ent setIsRead:[NSNumber numberWithInt:1]];
		NSError *error = nil;
		if (![[dbManagedObjectContext managedObjectContext] save:&error]) {
			[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Settings Save: %@!", [error userInfo]]];
			abort();
		}
	}
}

#pragma mark -
#pragma mark Interface

- (void)setRightNavItems {
	SilentToolbar *toolbar = [[SilentToolbar alloc] initWithFrame:CGRectMake(0, 0, 120, 44.4)];
	[toolbar setBarStyle: UIBarStyleBlackTranslucent];
	[toolbar setBackgroundColor:[UIColor clearColor]];
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:5];
	
	UIBarButtonItem *btnActions = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(doFeed:)];
	btnActions.style = UIBarButtonItemStyleBordered;
	[buttons addObject:btnActions];
	[btnActions release];
	
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:spacer];
	[spacer release];
	
	UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(openPrevFeed:)];
	btnPrev.style = UIBarButtonItemStyleBordered;
	[buttons addObject:btnPrev];
	[btnPrev release];
	
	spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:spacer];
	[spacer release];
	
	UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(openNextFeed:)];
	btnNext.style = UIBarButtonItemStyleBordered;
	[buttons addObject:btnNext];
	[btnNext release];
	
	[toolbar setItems:buttons animated:NO];
	[buttons release];
	
	UIBarButtonItem *rightBarItems = [[UIBarButtonItem alloc]  initWithCustomView:toolbar];
	rightBarItems.style = UIBarStyleBlackTranslucent;
	self.navigationItem.rightBarButtonItem = rightBarItems;
	[rightBarItems release];
	[toolbar release];
}

- (void)doFeed:(id)sender {
	self.feedActionsView = nil;
	self.feedActionsView = [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
	
	// Safari ========================================================
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 1;
	[btn setEnabled:TRUE];
	[btn setBackgroundImage:[[UIImage imageNamed:@"safari.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
	[btn setFrame:CGRectMake(40, 40, 30, 31)];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
	[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionSafari:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];

	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 2;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(40, 64, 30, 31)];
	[btn setTitle:@"Open" forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionSafari:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];
	
	// Instapaper ========================================================
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 3;
	[btn setEnabled:TRUE];
	[btn setBackgroundImage:[[UIImage imageNamed:@"instapaper.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
	[btn setFrame:CGRectMake(120, 40, 30, 31)];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
	[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionInstapaper:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 4;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(106, 64, 60, 31)];
	[btn setTitle:@"Instapaper" forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionInstapaper:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];

	// Email ========================================================
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 5;
	[btn setEnabled:TRUE];
	[btn setBackgroundImage:[[UIImage imageNamed:@"mail.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
	[btn setFrame:CGRectMake(190, 40, 30, 31)];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
	[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionMail:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 6;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(176, 64, 60, 31)];
	[btn setTitle:NSLocalizedString(@"Common.Mail", @"") forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionMail:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];

	// Close ========================================================
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.tag = 99;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(18, 360, 290, 44)];
	[btn setBackgroundImage:[[UIImage imageNamed:@"black-button.jpg"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
	[btn setTitle:NSLocalizedString(@"Common.Close", @"") forState:UIControlStateNormal];
	[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
	[btn setBackgroundColor:[UIColor clearColor]];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(actionCloseDo:) forControlEvents:UIControlEventTouchUpInside];
	[self.feedActionsView addSubview:btn];
}

#pragma mark -
#pragma mark Do Actions

- (void)actionCloseDo:(id)sender {
	[self.feedActionsView performSelector:@selector(removeView) withObject:nil afterDelay:0];
}

- (void)actionSafari:(id)sender {
	NSURL *url = [[NSURL alloc] initWithString:self.feedDataObject.URL];
	[[UIApplication sharedApplication] openURL:url];
	[url release];
}

- (void)actionInstapaper:(id)sender {
	SNInstapaper *ip = [[SNInstapaper alloc] init];
	[ip setDelegate:self];
	[ip send:self.feedDataObject];
	[ip release];
}

- (void)actionMail:(id)sender {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail])
			[self displayComposerSheet];
		else
			[self launchMailAppOnDevice];
	}
	else
		[self launchMailAppOnDevice];
}

#pragma mark -
#pragma mark Email

- (void)displayComposerSheet {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		[picker setSubject:[NSString stringWithFormat:@"Duduka - %@", self.feedDataObject.Title]];
		[picker setToRecipients:nil];
		[picker setBccRecipients:nil];
		[picker setCcRecipients:nil];

		NSMutableString *emailBody = [[NSMutableString alloc] init];
		[emailBody setString:@""];
		[emailBody appendFormat:@"%@<br><br>", self.feedDataObject.Title];
		[emailBody appendFormat:@"%@ <a href=\"%@\">%@</a><br><br>", NSLocalizedString(@"Email.ReadItHere", @""), self.feedDataObject.URL, self.feedDataObject.URL];
		[emailBody appendFormat:@"%@ <a href=\"%@\">%@</a><br>", NSLocalizedString(@"Email.CommentItHere", @""), self.feedDataObject.URLComments, self.feedDataObject.URLComments];

		[picker setMessageBody:emailBody isHTML:YES];
		[emailBody release];
		picker.navigationBar.barStyle = UIBarStyleBlack;

		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	else {
		[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
		BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Email.CannotSend", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)launchMailAppOnDevice {
	NSMutableString *emailBody = [[NSMutableString alloc] init];
	[emailBody setString:@""];
	[emailBody appendFormat:@"%@<br><br>", self.feedDataObject.Title];
	[emailBody appendFormat:@"%@ <a href=\"%@\">%@</a><br><br>", NSLocalizedString(@"Email.ReadItHere", @""), self.feedDataObject.URL, self.feedDataObject.URL];
	[emailBody appendFormat:@"%@ <a href=\"%@\">%@</a><br>", NSLocalizedString(@"Email.CommentItHere", @""), self.feedDataObject.URLComments, self.feedDataObject.URLComments];

	NSString *email = [NSString stringWithFormat:@"mailto:?cc=&bcc=&subject=Duduka - %@&body=%@", self.feedDataObject.Title, emailBody];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			[[AppSettings sharedAppSettings] LogThis:@"Email canceled."];
			break;
		case MFMailComposeResultSaved:
			[[AppSettings sharedAppSettings] LogThis:@"Email saved."];
			break;
		case MFMailComposeResultSent:
			[[AppSettings sharedAppSettings] LogThis:@"Email sent."];
			break;
		case MFMailComposeResultFailed:
			[[AppSettings sharedAppSettings] LogThis:@"Email failed."];
			break;
		default: {
			[[AppSettings sharedAppSettings] LogThis:@"Email not sent."];
			[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
			BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Email.Sending", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
	}
	[self actionCloseDo:nil];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Feed Nav

- (void)openPrevFeed:(id)sender {
	NSInteger r = self.indexPath.row - 1;
	if (r <= 0)
		r = 0;
	NSIndexPath *ix = [NSIndexPath indexPathForRow:r inSection:self.indexPath.section];
	self.feedDataObject = [self.fetchedResultsController objectAtIndexPath:ix];
	self.indexPath = ix;
	[self viewWillAppear:YES];
}

- (void)openNextFeed:(id)sender {
	NSIndexPath *ix;
	NSInteger r = self.indexPath.row + 1;
	if (r >= [[[fetchedResultsController sections] objectAtIndex:self.indexPath.section] numberOfObjects])
		r = [[[fetchedResultsController sections] objectAtIndex:self.indexPath.section] numberOfObjects] - 1;
	ix = [NSIndexPath indexPathForRow:r inSection:self.indexPath.section];
	self.feedDataObject = [self.fetchedResultsController objectAtIndexPath:ix];
	self.indexPath = ix;
	[self viewWillAppear:YES];
}

#pragma mark -
#pragma mark Delegates

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	CGRect frame = [webView frame];
	frame.size.height = 1;
	[webView setFrame:frame];
	frame.size.height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
	[webView setFrame:frame];
	
	frame = [self.wvContent frame];
	frame.origin.y = 20;
	frame.size.height = (webView.frame.origin.y + webView.frame.size.height + 40);
	if (frame.size.height < 380)
		frame.size.height = 380;
	[self.wvContent setFrame:frame];
	
	CGSize newsize = CGSizeMake(self.wvContent.frame.size.width * 4.0, self.wvContent.frame.size.height * 4.0);
    self.viewScroll.contentSize = newsize;
	self.viewScroll.clipsToBounds = YES;
}

- (void)InstapaperSubmitSuccess:(id)sender {
	[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
	BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SN.Instapaper.Success", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", @"") otherButtonTitles:nil];
	alert.tag = 90;
	[alert show];
	[alert release];
}

- (void)InstapaperSubmitFailed:(id)sender errorMessage:(NSString *)errorMessage {
	[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
	BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:errorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", @"") otherButtonTitles:NSLocalizedString(@"Common.Retry", @""), nil];
	alert.tag = 91;
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 90)
		[self actionCloseDo:nil];
	else if (actionSheet.tag == 91) {
		if (buttonIndex == 0)
			[self actionCloseDo:nil];
		else
			[self actionInstapaper:self.feedDataObject];
	}
}

#pragma mark -
#pragma mark System

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
	[self.wvContent stopLoading];
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[feedDataObject release];
	[viewScroll release];
	[wvContent release];
	[feedActions release];
	[fetchedResultsController release];
	[indexPath release];
	[feedActionsView release];
    [super dealloc];
}

@end
