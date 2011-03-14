//
//  SocialNetworks.m
//  Duduka
//
//  Created by Sergey Petrov on 9/8/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "SocialNetworks.h"
#import "SocialNetworksInstapaper.h"

static NSString *kCellIdentifier = @"MyIdentifier";

@implementation SocialNetworks

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Settings.Item.SocialNetworks", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Settings.SN.Instapaper", @"");
			cell.imageView.image = [UIImage imageNamed:@"instapaper.png"];
			break;
		default:
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: {
			SocialNetworksInstapaper *tvc = [[SocialNetworksInstapaper alloc] initWithNibName:@"SocialNetworksInstapaper" bundle:nil];
			[[self navigationController] pushViewController:tvc animated:YES];
			[tvc release];
			break;
		}
		default:
			break;
	}
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
