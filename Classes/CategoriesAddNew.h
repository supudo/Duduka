//
//  CategoriesAddNew.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dbCategory.h"

@interface CategoriesAddNew : UIViewController {
	dbCategory *parentCategory;
	UILabel *lblParentLabel, *lblParentTitle;
	UITextField *txtCategory;
}

@property (nonatomic, retain) dbCategory *parentCategory;
@property (nonatomic, retain) IBOutlet UILabel *lblParentLabel, *lblParentTitle;
@property (nonatomic, retain) IBOutlet UITextField *txtCategory;

- (void)saveCategory:(id)sender;

@end
