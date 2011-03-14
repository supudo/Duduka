//
//  URLReader.m
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import "URLReader.h"

@implementation URLReader

@synthesize delegate;

- (NSString *)getFromURL:(NSString *)URL postData:(NSString *)pData {
	NSData *postData = [pData dataUsingEncoding:NSASCIIStringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:URL]];
	[request setHTTPMethod:@"GET"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	if (error != nil && [error localizedDescription] != nil) {
		data = @"";
		[[AppSettings sharedAppSettings] LogThis:[NSString stringWithFormat:@"ENC - Connection Failed: %@", [error localizedDescription]]];
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(urlRequestError:errorMessage:)])
			[delegate urlRequestError:self errorMessage:[error localizedFailureReason]];
	}
	
	return [data autorelease];
}

- (NSData *)getFaviconData:(NSString *)URL {
	NSMutableString *faviconURL = [[NSMutableString alloc] init];
	[faviconURL setString:[self getFaviconURL:URL]];
	if (NSEqualRanges(NSMakeRange(NSNotFound, 0), [faviconURL rangeOfString:@"http://"]))
		[faviconURL setString:[NSString stringWithFormat:@"%@/%@", URL, faviconURL]];
	NSError *error = nil;
	NSURLResponse *response;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:faviconURL]];
	[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	return data;
}

- (NSString *)getFaviconURL:(NSString *)URL {
	NSError *error = nil;
	NSURLResponse *response;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:URL]];
	[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	NSScanner *htmlScanner = [NSScanner scannerWithString:htmlString];
	[htmlString release];
	while ([htmlScanner isAtEnd] == NO) {
		[htmlScanner scanUpToString:@"<link" intoString:NULL];
		if (![htmlScanner isAtEnd]) {
			NSString *linkString;
			[htmlScanner scanUpToString:@"/>" intoString:&linkString];

			if (([linkString rangeOfString:@"rel=\"shortcut icon\""].location != NSNotFound) ||
			   ([linkString rangeOfString:@"rel='shortcut icon'"].location != NSNotFound) ||
			   ([linkString rangeOfString:@"rel=\"icon\""].location != NSNotFound) ||
			   ([linkString rangeOfString:@"rel='icon'"].location != NSNotFound) ||
			   ([linkString rangeOfString:@"rel=icon "].location != NSNotFound))
			{
				NSScanner *hrefScanner = [NSScanner scannerWithString:linkString];
				[hrefScanner scanUpToString:@"href=" intoString:NULL];
				if (![hrefScanner isAtEnd]) {
					[hrefScanner scanString:@"href=" intoString:NULL];
					NSString *hrefString;
					[hrefScanner scanUpToString:@" " intoString:&hrefString];
					hrefString = [hrefString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
					hrefString = [hrefString stringByReplacingOccurrencesOfString:@"'" withString:@""];
					return hrefString;
				}
			}
		}
	}
	return nil;
}



- (NSString *)urlCryptedEncode:(NSString *)stringToEncrypt {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																		   NULL,
																		   (CFStringRef)stringToEncrypt,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																		   kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
