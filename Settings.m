//
//  Settings.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "Settings.h"
#import "DBManagedObjectContext.h"
#import "BlackAlertView.h"
#import "AutoRefreshInterval.h"
#import "SocialNetworks.h"

static NSString *kCellIdentifier = @"MyIdentifier";

@implementation Settings

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	switch (indexPath.row) {
		case 0: {
			cell.textLabel.text = NSLocalizedString(@"Settings.Item.AutoRefresh", @"");
			cell.imageView.image = [UIImage imageNamed:@"refresh.png"];
			break;
		}
		case 1: {
			cell.textLabel.text = NSLocalizedString(@"Settings.Item.WipeData", @"");
			cell.detailTextLabel.text = NSLocalizedString(@"Settings.Item.WipeDataWarning", @"");
			cell.imageView.image = [UIImage imageNamed:@"wipe-data.png"];
			break;
		}
		case 2: {
			cell.textLabel.text = NSLocalizedString(@"Settings.Item.SocialNetworks", @"");
			cell.imageView.image = [UIImage imageNamed:@"social-nets.png"];
			break;
		}
		default:
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: {
			AutoRefreshInterval *tvc = [[AutoRefreshInterval alloc] initWithNibName:@"AutoRefreshInterval" bundle:nil];
			[[self navigationController] pushViewController:tvc animated:YES];
			[tvc release];
			break;
		}
		case 1: {
			[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
			BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Settings.WipePrompt", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", @"") otherButtonTitles:NSLocalizedString(@"Common.Cancel", @""), nil];
			alert.tag = 90;
			[alert show];
			[alert release];
			break;
		}
		case 2: {
			SocialNetworks *tvc = [[SocialNetworks alloc] initWithNibName:@"SocialNetworks" bundle:nil];
			[[self navigationController] pushViewController:tvc animated:YES];
			[tvc release];
			break;
		}
		default:
			break;
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 90 && buttonIndex == 0)
		[NSThread detachNewThreadSelector:@selector(startThreadWipeOutData) toTarget:self withObject:nil];
	else if (actionSheet.tag == 91) {
		[appDelegate tabBarController].selectedIndex = 0;
		[[appDelegate tabBarController] viewWillAppear:YES];
		[[[appDelegate tabBarController].viewControllers objectAtIndex:0] popToRootViewControllerAnimated:NO];
	}
}

- (void)startThreadWipeOutData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//[NSThread sleepForTimeInterval:4];
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	[dbManagedObjectContext wipeoutData];
	[self performSelectorOnMainThread: @selector(wipeoutDataFinished) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void)wipeoutDataFinished {
	[BlackAlertView setBackgroundColor:[UIColor blackColor] withStrokeColor:[UIColor whiteColor]];
	BlackAlertView *alert = [[BlackAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Settings.WipeoutFinished", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Common.OK", @"") otherButtonTitles:NSLocalizedString(@"Common.Cancel", @""), nil];
	alert.tag = 91;
	[alert show];
	[alert release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

@end
