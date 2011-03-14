//
//  RssParser.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "RssParser.h"
#import "DBManagedObjectContext.h"

@implementation RssParser

@synthesize delegate, urlReader, managedObjectContext, feedCategory, feed, feedData, URL;
@synthesize siteURL, currentElement, isChannelData, errorOccured, xmlStringContents;

- (void)startParse:(NSString *)feedURL category:(dbCategory *)cat {
	self.URL = feedURL;
	self.feedCategory = cat;
	if (self.urlReader == nil)
		self.urlReader = [[URLReader alloc] init];
	[urlReader setDelegate:self];
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserProgress:progress:)])
		[delegate parserProgress:self progress:@"Quering the URL..."];
	NSString *xmlData = [urlReader getFromURL:URL postData:@""];
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserProgress:progress:)])
		[delegate parserProgress:self progress:@"Response received..."];
	if (xmlData.length > 0) {
		self.errorOccured = FALSE;
		self.isChannelData = TRUE;
		//[[AppSettings sharedAppSettings] LogThis:xmlData];
		self.xmlStringContents = xmlData;
		//xmlData = [xmlData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		//xmlData = [xmlData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
		//xmlData = [xmlData stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		//[[AppSettings sharedAppSettings] LogThis:xmlData];
		NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:[xmlData dataUsingEncoding:NSUTF8StringEncoding]];
		[myParser setDelegate:self];
		[myParser setShouldProcessNamespaces:NO];
		//[myParser setShouldReportNamespacePrefixes:NO];
		//[myParser setShouldResolveExternalEntities:NO];
		[myParser parse];
		[myParser release];
	}
	else if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserFinished:)])
		[delegate parserFinished:self];
}

- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage {
	self.errorOccured = TRUE;
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserError:error:)])
		[delegate parserError:self error:errorMessage];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.errorOccured = TRUE;
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserError:error:)])
		[delegate parserError:self error:[parseError localizedDescription]];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserProgress:progress:)])
		[delegate parserProgress:self progress:@"Starting the parser..."];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	DBManagedObjectContext *dbManagedObjectContext = [DBManagedObjectContext sharedDBManagedObjectContext];
	currentElement = [elementName lowercaseString];
	if (self.isChannelData && [currentElement isEqualToString:@"channel"]) {
		self.isChannelData = TRUE;
	}
	else if (self.isChannelData && [currentElement isEqualToString:@"title"]) {
		self.feed = (dbFeed *)[dbManagedObjectContext getEntity:@"Feed" predicate:[NSPredicate predicateWithFormat:@"URL = %@", self.URL]];
		if (self.feed == nil)
			self.feed = (dbFeed *)[NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		else {
			[dbManagedObjectContext deleteObjects:@"FeedData" predicate:[NSPredicate predicateWithFormat:@"feed = %@", self.feed]];
			NSError *error = nil;
			if (![[[DBManagedObjectContext sharedDBManagedObjectContext] managedObjectContext] save:&error]) {
				[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Feed data delete: %@!", [error userInfo]]];
				abort();
			}
		}
		[self.feed setURL:self.URL];
		[self.feed setCategory:self.feedCategory];
		[self.feed setLastUpdateDate:[NSDate date]];
		[self.feed setLastRefreshDate:[NSDate date]];
	}
	else if ([currentElement isEqualToString:@"item"]) {
		self.isChannelData = FALSE;
		self.feedData = (dbFeedData *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedData" inManagedObjectContext:[dbManagedObjectContext managedObjectContext]];
		[self.feedData setFeed:self.feed];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	if (![string isEqualToString:@""]) {
		if (self.isChannelData && [currentElement isEqualToString:@"description"])
			[self.feed setDescription:string];
		else if (self.isChannelData && [currentElement isEqualToString:@"title"])
			[self.feed setTitle:string];
		else if (self.isChannelData && [currentElement isEqualToString:@"link"]) {
			if (self.urlReader == nil)
				self.urlReader = [[URLReader alloc] init];
			[self.feed setFavicon:[self.urlReader getFaviconData:string]];
			self.siteURL = string;
		}

		else if (!self.isChannelData && [currentElement isEqualToString:@"title"])
			[self.feedData setTitle:string];
		else if (!self.isChannelData && [currentElement isEqualToString:@"link"])
			[self.feedData setURL:string];
		else if (!self.isChannelData && [currentElement isEqualToString:@"comments"])
			[self.feedData setURLComments:string];
		else if (!self.isChannelData && [currentElement isEqualToString:@"dc:creator"])
			[self.feedData setAuthor:string];
		else if (!self.isChannelData && [currentElement isEqualToString:@"content:encoded"])
			[self.feedData setContent:[string stringByReplacingOccurrencesOfString:@"<img src=\"/" withString:[NSString stringWithFormat:@"<img src=\"%@/", self.siteURL]]];
		else if (!self.isChannelData && [currentElement isEqualToString:@"pubdate"]) {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"]; // Sun, 29 Aug 2010 06:44:20 +0000
			[self.feedData setDate:[df dateFromString: [string stringByReplacingOccurrencesOfString:@" +0000" withString:@""]]];
			[df release];
		}
		else if (!self.isChannelData && [currentElement isEqualToString:@"category"]) {
			if (self.feedData.LocalCategories == nil || string == nil)
				[self.feedData setLocalCategories:string];
			else
				[self.feedData setLocalCategories:[NSString stringWithFormat:@"%@, %@", self.feedData.LocalCategories, string]];
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSError *error = nil;
	if (![[[DBManagedObjectContext sharedDBManagedObjectContext] managedObjectContext] save:&error]) {
		[[AppSettings sharedAppSettings] LogThis: [NSString stringWithFormat:@"Feed save: %@!", [error userInfo]]];
		abort();
	}

	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserProgress:progress:)])
		[delegate parserProgress:self progress:@"Finished."];
	if (!self.errorOccured && self.delegate != NULL && [self.delegate respondsToSelector:@selector(parserFinished:)])
		[delegate parserFinished:self];
}

- (void)dealloc {
	[delegate release];
	[urlReader release];
	[feedCategory release];
	[feed release];
	[feedData release];
	[currentElement release];
	[URL release];
	[managedObjectContext release]; 
	[xmlStringContents release];
	[siteURL release];
	[super dealloc];
}

@end
