//
//  FeedsAddNew.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dbCategory.h"
#import "dbFeed.h"
#import "RssParser.h"

@interface FeedsAddNew : UIViewController <RssParserDelegate> {
	UIActionSheet *loadingActionSheet;
	dbCategory *parentCategory;
	UILabel *lblParentLabel, *lblParentTitle, *lblProgress;
	UITextField *txtFeedURL;
	RssParser *rssParser;
}

@property (nonatomic, retain) UIActionSheet *loadingActionSheet;
@property (nonatomic, retain) dbCategory *parentCategory;
@property (nonatomic, retain) IBOutlet UILabel *lblParentLabel, *lblParentTitle, *lblProgress;
@property (nonatomic, retain) IBOutlet UITextField *txtFeedURL;
@property (nonatomic, retain) RssParser *rssParser;

- (void)saveFeed:(id)sender;
- (void) showLoadingSheet;
- (void) hideLoadingSheet;

@end
