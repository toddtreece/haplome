//
//  BBOSCBundle.m
//  BBOSC-Cocoa
//
//  Created by ben smith on 7/18/08.
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
//

#import "BBOSCBundle.h"

#import "BBOSCDataUtilities.h"

@implementation BBOSCBundle

@synthesize timeStamp;
/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////
// a quick way to start a new bundle with a known timestamp
+(BBOSCBundle*)bundleWithTimestamp:(NSDate*)aDate
{
	BBOSCBundle * newBundle = [[BBOSCBundle alloc] init];
	[newBundle setTimeStamp:aDate];
	return [newBundle autorelease];
}

/////////////////////////////////////////////////////////////////
// INSTACE METHODS
/////////////////////////////////////////////////////////////////

// generates an NSData object that holds the bytes in the OSC specified format 
// for this argument
-(NSData*)packetizedData
{
	// need to build up my packetized data block out of my messages and bundles
	// #bundle timestamp size1 object1 size2 object2 ... sizeN objectN
	// where the objects can be messages or other bundles
	
	// first, check to see if we have an 'easy' case
	if ([containedObjects count] == 0) return nil; 
	
	// ok, we are here so we have at least one contained obj, possibly more
	// make a container to store it all in, start with the #bundle keyword
	NSMutableData * packetData = [NSMutableData dataWithData:[BBOSCDataUtilities dataBlockFromString:@"#bundle"]];
	[packetData appendData:[BBOSCDataUtilities ntpTimestampFromNSDate:[self timeStamp]]];
	// now go through all the contained objects and add their packetized data
	// dont forget to add the size at the beginning
	for (id anObj in containedObjects) {
		NSData * thisData = [anObj packetizedData];
		[packetData appendData:[BBOSCDataUtilities dataBlockFromInt:[thisData length]]];
		[packetData appendData:thisData];
	}
	
	// that's it!
	return packetData;
}

// this is really just for debugging and logging purposes
// it is a handy way to look at your message data
-(NSString*)stringRepresentation
{
	NSMutableString * stringRep = [NSMutableString string];
	[stringRep appendFormat:@"BUNDLE:\ntime: %@",[self timeStamp]];
	
	// now iterate across all my arguments and get all the types
	for (BBOSCPacket * packet in containedObjects) {
		[stringRep appendFormat:@"\n---\n%@",[packet stringRepresentation]];
	}
	return stringRep;
}

- (void) dealloc
{
	[timeStamp release];
	[super dealloc];
}

@end
