//
//  Notes.m
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "Notes.h"
#import <QuartzCore/QuartzCore.h>
#import "MCSegmentedControl.h"
#import "UINavigationItemCleanBG.h"

@implementation Notes

@synthesize scrollView, textView, colorsView, txtNotes, barActions, isDrawing, isSelectingColor, notesDrawView;

- (void)viewDidLoad {
	[super viewDidLoad];

	MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Notes.Menu.Text", @""), NSLocalizedString(@"Notes.Menu.Draw", @""), nil]];
	segmentedControl.frame = CGRectMake(6, 2, 306, 30);
	[segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.tintColor = [UIColor whiteColor];
	segmentedControl.selectedItemColor = [UIColor blackColor];
	segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
	segmentedControl.selectedSegmentIndex = 0;
	self.navigationItem.titleView = segmentedControl;

	[self setupDrawingActions];

	self.scrollView.delegate = self;
	if (self.notesDrawView == nil)
		self.notesDrawView = [[NotesDrawView alloc] initWithNibName:@"NotesDrawView" bundle:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.isSelectingColor = FALSE;
	self.isDrawing = FALSE;
	[self segmentedControlDidChange:nil];
}

- (void)setupDrawingActions {
	if (self.barActions == nil) {
		self.barActions = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44.4)];
		[self.barActions setBarStyle: UIBarStyleBlackTranslucent];
		[self.barActions setBackgroundColor:[UIColor blackColor]];
	}
	
	// Left button
	SilentToolbar *toolbar = [[SilentToolbar alloc] initWithFrame:CGRectMake(0, 0, 120, 44.4)];
	[toolbar setBarStyle: UIBarStyleBlackTranslucent];
	[toolbar setBackgroundColor:[UIColor clearColor]];

	NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Notes.Save", @"") style:UIBarButtonItemStyleDone target:self action:@selector(doSave:)];
	[buttons addObject:btn];
	[btn release];
	
	btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:btn];
	[btn release];
	
	btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Notes.Clear", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(doClear:)];
	[buttons addObject:btn];
	[btn release];

	[toolbar setItems:buttons animated:NO];
	[buttons release];
	
	UINavigationItem *navItem = [[UINavigationItem alloc] init];

	UIBarButtonItem *leftBarItems = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	leftBarItems.style = UIBarStyleBlackTranslucent;
	navItem.leftBarButtonItem = leftBarItems;
	
	UIBarButtonItem *rightBarItems = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	rightBarItems.style = UIBarStyleBlackTranslucent;
	navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Notes.Color", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(doColor:)];

	[self.barActions pushNavigationItem:navItem animated:NO];
	[leftBarItems release];
	[rightBarItems release];
	[toolbar release];
}

- (void)doSave:(id)sender {
}

- (void)doClear:(id)sender {
	self.notesDrawView.imgNotes.image = nil;
}

- (void)doColor:(id)sender {
	if (self.isSelectingColor) {
		[self.colorsView setHidden:YES];
		self.isSelectingColor = FALSE;
	}
	else {
		if (self.colorsView == nil)
			[self setupColorsView];
		[self.colorsView setHidden:NO];
		self.isSelectingColor = YES;
	}
}

- (void)setupColorsView {
	self.colorsView = [[UIView alloc] initWithFrame:CGRectMake(270, 50, 40, 145)];
	[self.colorsView setBackgroundColor:[UIColor lightGrayColor]];
	//[self.colorsView setAlpha:0.30];

	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 1;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(5, 5, 30, 30)];
	[btn setBackgroundColor:[UIColor redColor]];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
	[self.colorsView addSubview:btn];

	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 2;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(5, 40, 30, 30)];
	[btn setBackgroundColor:[UIColor greenColor]];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
	[self.colorsView addSubview:btn];

	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 3;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(5, 75, 30, 30)];
	[btn setBackgroundColor:[UIColor blueColor]];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
	[self.colorsView addSubview:btn];

	btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.tag = 4;
	[btn setEnabled:TRUE];
	[btn setFrame:CGRectMake(5, 110, 30, 30)];
	[btn setBackgroundColor:[UIColor blackColor]];
	[btn setTitle:@"" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
	[self.colorsView addSubview:btn];

	[self.view addSubview:self.colorsView];
}

- (void)selectColor:(id)sender {
	UIButton *btn = (UIButton *)sender;
	self.notesDrawView.fRed = 0.0;
	self.notesDrawView.fGreen = 0.0;
	self.notesDrawView.fBlue = 0.0;
	switch (btn.tag) {
		case 1:
			self.notesDrawView.fRed = 1.0;
			break;
		case 2:
			self.notesDrawView.fGreen = 1.0;
			break;
		case 3:
			self.notesDrawView.fBlue = 1.0;
			break;
		default:
			break;
	}
	[self doColor:nil];
}

- (void)segmentedControlDidChange:(id)sender {
	if (self.isDrawing) {
		[self.textView removeFromSuperview];
		[self.scrollView addSubview:self.notesDrawView.view];
		self.isDrawing = FALSE;
		[self setupDrawingActions];
		[self.view addSubview:barActions];
	}
	else {
		[self.barActions removeFromSuperview];
		[self.scrollView addSubview:self.textView];
		self.isDrawing = TRUE;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[scrollView release];
	[textView release];
	[colorsView release];
	[txtNotes release];
	[barActions release];
	[notesDrawView release];
    [super dealloc];
}

@end
