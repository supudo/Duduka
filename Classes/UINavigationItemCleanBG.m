//
//  UINavigationItemCleanBG.m
//  Duduka
//
//  Created by Sergey Petrov on 9/7/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "UINavigationItemCleanBG.h"

static const NSUInteger kToolbarHeight = 45;

@implementation SilentToolbar
- (id)initWithFrame:(CGRect)frame {
    [super initWithFrame:frame];
    [self setBarStyle:UIBarStyleBlackOpaque];
    [self setBackgroundColor:[UIColor clearColor]];
    return self;
}
- (void)drawRect:(CGRect)rect {}
@end

@implementation UINavigationItem (UINavigationItemCleanBG)
- (void)setRightBarButtonItemsWithTotalWidth:(NSUInteger)width items:(UIBarItem *)firstItem, ... {
    va_list args;
    va_start(args, firstItem);
    NSMutableArray *items = [NSMutableArray array];
    UIBarItem *item = firstItem;
    while (item != nil) {
        [items addObject:item];
        item = va_arg(args, UIBarItem*);
    }
    va_end(args);
	
    UIToolbar *toolbar = [[SilentToolbar alloc] initWithFrame:CGRectMake(0, 0, width, kToolbarHeight)];
    [toolbar setItems:items animated:NO];
    UIBarButtonItem *wrapper = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    [self setRightBarButtonItem:wrapper animated:NO];
    [wrapper release];
    [toolbar release];
}
@end
