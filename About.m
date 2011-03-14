//
//  About.m
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "About.h"

@implementation About

@synthesize lblCopyright, lblVersion, txtCC;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.lblCopyright.text = NSLocalizedString(@"About.Copyright", @"");
	self.lblVersion.text = [NSString stringWithFormat:NSLocalizedString(@"About.Version", @""), [AppSettings sharedAppSettings].AppVersion];
	NSMutableString *cc = [[NSMutableString alloc] init];
	[cc setString:@"Icons by Joseph Wain / glyphish.com\n\n"];
	[cc appendFormat:@"More icons from m0rphzilla / m0rphzilla.deviantart.com\n\n"];
	[cc appendFormat:@"Some code from Matt Gallagher / cocoawithlove.com\n\n"];
	[cc appendFormat:@"Some code from Matteo Caldari / matteocaldari.it\n\n"];
	self.txtCC.text = cc;
	self.txtCC.font = [UIFont fontWithName:@"Helvetica" size:14];
	self.txtCC.textAlignment = UITextAlignmentCenter;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[lblCopyright release];
	[lblVersion release];
	[txtCC release];
    [super dealloc];
}

@end
