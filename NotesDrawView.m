//
//  NotesDrawView.m
//  Duduka
//
//  Created by Sergey Petrov on 9/9/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "NotesDrawView.h"

@implementation NotesDrawView

@synthesize imgNotes, fRed, fGreen, fBlue, fWidth;

- (void)viewDidLoad {
	[super viewDidLoad];
	fRed = 0.0;
	fGreen = 0.0;
	fBlue = 0.0;
	fWidth = 1.0;
	mouseMoved = 0;
}

- (void)actionSave:(id)sender {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = NO;
	lastPoint = [[touches anyObject] locationInView:self.imgNotes];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self.imgNotes];
	
	UIGraphicsBeginImageContext(self.imgNotes.frame.size);
	[self.imgNotes.image drawInRect:CGRectMake(0, 0, self.imgNotes.frame.size.width, self.imgNotes.frame.size.height)];
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), fWidth);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), fRed, fGreen, fBlue, 1.0);
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	self.imgNotes.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	lastPoint = currentPoint;
	mouseMoved++;

	if (mouseMoved == 10)
		mouseMoved = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!mouseSwiped) {
		UIGraphicsBeginImageContext(self.imgNotes.frame.size);
		[self.imgNotes.image drawInRect:CGRectMake(0, 0, self.imgNotes.frame.size.width, self.imgNotes.frame.size.height)];
		CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), fWidth);
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), fRed, fGreen, fBlue, 1.0);
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		CGContextFlush(UIGraphicsGetCurrentContext());
		self.imgNotes.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ? NO : YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[imgNotes release];
    [super dealloc];
}

@end
