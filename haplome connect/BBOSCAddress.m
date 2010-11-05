//
//  BBOSCAddress.m
//  BBOSC-Cocoa
//
//  This file is part of BBOSC-Cocoa.
//
//  BBOSC-Cocoa is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  BBOSC-Cocoa is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.

//  You should have received a copy of the GNU Lesser General Public License
//  along with BBOSC-Cocoa.  If not, see <http://www.gnu.org/licenses/>.
// 
//  Copyright 2008 Ben Britten Smith ben@benbritten.com .
//
//

#import "BBOSCAddress.h"

#import "BBOSCDataUtilities.h"

@implementation BBOSCAddress

@synthesize address;

/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////

// a cenvenience method to create addresses with strings
// (which is probably the generl way that it usually happens
// a call to this method would look like:
// BBOSCAddress * myAddress = [BBOSCAddress addressWithString:@"/component/3/buzz"];
+(BBOSCAddress*)addressWithString:(NSString*)addressString
{
	BBOSCAddress * newOSCAddress = [[BBOSCAddress alloc] initWithString:addressString];
	return [newOSCAddress autorelease];
}

// a slightly more 'advanced' way to get an address is to send an
// array of strings, each one a level in the dispatch hierarchy
// for instance:
// if the array looks like:
// index 0 -> @"component"
// index 1 -> @"5"
// index 2 -> @"resonate"
// then the resulting address will be: /component/5/resonate
// this is useful if you are building your OSC addresses programmatically
+(BBOSCAddress*)addressWithArray:(NSArray*)addressArray
{
	NSMutableString * newAddyString = [NSMutableString string];
	for (NSString* addressComponent in addressArray) {
		[newAddyString appendFormat:@"/%@",addressComponent];
	}
	BBOSCAddress * newOSCAddress = [[BBOSCAddress alloc] initWithString:newAddyString];
	return [newOSCAddress autorelease];
}


/////////////////////////////////////////////////////////////////
// INSTANCE METHODS
/////////////////////////////////////////////////////////////////


// the main init method.  takes a string and sets the address
// TODO, check for the 'bad' characters and throw and exception
- (id) initWithString:(NSString*)aString
{
	self = [super init];
	if (self != nil) {
		if (aString == nil) return nil;
		[self setAddress:aString];
	}
	return self;
}

// generates an NSData object that holds the bytes in the OSC specified format 
// for this address
-(NSData*)packetizedData
{
	return [BBOSCDataUtilities dataBlockFromString:[self address]];
}


- (void) dealloc
{
	[address release];
	[super dealloc];
}

@end
