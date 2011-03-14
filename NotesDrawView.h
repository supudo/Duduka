//
//  NotesDrawView.h
//  Duduka
//
//  Created by Sergey Petrov on 9/9/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesDrawView : UIViewController {
	UIImageView *imgNotes;
	CGPoint lastPoint;
	BOOL mouseSwiped;
	int mouseMoved;
	float fRed, fGreen, fBlue, fWidth;
}

@property (nonatomic, retain) IBOutlet UIImageView *imgNotes;
@property float fRed, fGreen, fBlue, fWidth;

@end
