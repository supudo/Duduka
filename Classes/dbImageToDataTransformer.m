//
//  dbCategoryImageToDataTransformer.m
//  iT-POS4
//
//  Created by Sergey Petrov on 3/5/10.
//  Copyright 2010 ElyonServices. All rights reserved.
//

#import "dbImageToDataTransformer.h"


@implementation dbImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}

- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return [uiImage autorelease];
}

@end
