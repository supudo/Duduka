//
//  About.h
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface About : UIViewController {
	UILabel *lblCopyright, *lblVersion;
	UITextView *txtCC;
}

@property (nonatomic, retain) IBOutlet UILabel *lblCopyright, *lblVersion;
@property (nonatomic, retain) IBOutlet UITextView *txtCC;

@end
