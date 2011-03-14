//
//  DudukaAppDelegate.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright n/a 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DudukaViewController;

@interface DudukaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)loadingFinished;
- (void)startBackgroundWorkers;

@end

extern DudukaAppDelegate *appDelegate;

