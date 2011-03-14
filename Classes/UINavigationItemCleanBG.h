//
//  UINavigationItemCleanBG.h
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UINavigationItem (UINavigationItemCleanBG)

- (void) setRightBarButtonItemsWithTotalWidth:(NSUInteger)width items:(UIBarItem *)firstItem, ...;

@end

@interface SilentToolbar : UIToolbar {}
@end
