//
//  Categories.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dbCategory.h"

@interface Categories : UITableViewController<NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	dbCategory *parentCategory;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) dbCategory *parentCategory;

- (void)addCategory:(id)sender;

@end
