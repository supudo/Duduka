//
//  RssParser.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbCategory.h"
#import "dbFeed.h"
#import "dbFeedData.h"
#import "URLReader.h"

@protocol RssParserDelegate <NSObject>
@optional
- (void)parserFinished:(id)sender;
- (void)parserProgress:(id)sender progress:(NSString *)subProgress;
- (void)parserError:(id)sender error:(NSString *)errorMessage;
@end

#ifdef __IPHONE_4_0
@interface RssParser : NSObject <NSXMLParserDelegate, URLReaderDelegate> {
#else
@interface RssParser : NSObject <URLReaderDelegate> {
#endif
	id<RssParserDelegate> delegate;
	URLReader *urlReader;
	NSManagedObjectContext *managedObjectContext;
	dbCategory *feedCategory;
	dbFeed *feed;
	dbFeedData *feedData;
	NSString *URL, *siteURL, *currentElement, *xmlStringContents;
	BOOL isChannelData, errorOccured;
}

@property (assign) id<RssParserDelegate> delegate;
@property (nonatomic, retain) URLReader *urlReader;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) dbCategory *feedCategory;
@property (nonatomic, retain) dbFeed *feed;
@property (nonatomic, retain) dbFeedData *feedData;
@property (nonatomic, retain) NSString *URL, *siteURL, *currentElement, *xmlStringContents;
@property BOOL isChannelData, errorOccured;

- (void)startParse:(NSString *)URL category:(dbCategory *)cat;

@end
