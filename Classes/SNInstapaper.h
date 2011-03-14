//
//  SNInstapaper.h
//  Duduka
//
//  Created by Sergey Petrov on 9/8/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbFeedData.h"

@protocol SNInstapaperDelegate <NSObject>
@optional
- (void)InstapaperSubmitSuccess:(id)sender;
- (void)InstapaperSubmitFailed:(id)sender errorMessage:(NSString *)errorMessage;
@end

@interface SNInstapaper : NSObject {
	id<SNInstapaperDelegate> delegate;
}

@property (assign) id<SNInstapaperDelegate> delegate;

- (void)send:(dbFeedData *)feed;

@end
