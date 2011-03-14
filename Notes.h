//
//  Notes.h
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesDrawView.h"

@class NotesDrawView;

@interface Notes : UIViewController <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIView *textView, *colorsView;
	UITextView *txtNotes;
	UINavigationBar *barActions;
	BOOL isDrawing, isSelectingColor;
	NotesDrawView *notesDrawView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *textView, *colorsView;
@property (nonatomic, retain) IBOutlet UITextView *txtNotes;
@property (nonatomic, retain) IBOutlet UINavigationBar *barActions;
@property BOOL isDrawing, isSelectingColor;
@property (nonatomic, retain) NotesDrawView *notesDrawView;

- (void)segmentedControlDidChange:(id)sender;
- (void)setupDrawingActions;
- (void)doSave:(id)sender;
- (void)doClear:(id)sender;
- (void)doColor:(id)sender;
- (void)setupColorsView;

@end
