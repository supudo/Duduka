//
//  URLReader.h
//  Duduka
//
//  Created by Sergey Petrov on 8/30/10.
//  Copyright 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLReaderDelegate <NSObject>
@optional
- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage;
@end

@interface URLReader : NSObject {
	id<URLReaderDelegate> delegate;
}

@property (assign) id<URLReaderDelegate> delegate;

- (NSString *)getFromURL:(NSString *)URL postData:(NSString *)pData;
- (NSData *)getFaviconData:(NSString *)URL;
- (NSString *)getFaviconURL:(NSString *)URL;
- (NSString *)urlCryptedEncode:(NSString *)stringToEncrypt;

@end
