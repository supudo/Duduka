//
//  SocialNetworksInstapaper.h
//  Duduka
//
//  Created by Sergey Petrov on 9/8/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SocialNetworksInstapaper : UIViewController {
	UILabel *lblUsername, *lblPassword;
	UITextField *txtUsername, *txtPassword;
}

@property (nonatomic, retain) IBOutlet UILabel *lblUsername, *lblPassword;
@property (nonatomic, retain) IBOutlet UITextField *txtUsername, *txtPassword;

@end
