//
//  BBOSCMessage.m
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

#import "BBOSCMessage.h"

#import "BBOSCArgument.h"
#import "BBOSCDataUtilities.h"

@implementation BBOSCMessage

@synthesize address;

/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////
// a simple convenience method for making basic messages
+(BBOSCMessage*)messageWithBBOSCAddress:(BBOSCAddress*)anAddress
{
	BBOSCMessage * newMessage = [[BBOSCMessage alloc] initWithBBOSCAddress:anAddress];
	return [newMessage autorelease];
}


/////////////////////////////////////////////////////////////////
// INSTANCE METHODS
/////////////////////////////////////////////////////////////////
- (id) initWithBBOSCAddress:(BBOSCAddress*)anAddress
{
	self = [super init];
	if (self != nil) {
		if (anAddress == nil) return nil;
		[self setAddress:anAddress];
	}
	return self;
}

// attaching arguments is how you, well, attach arguments to a message
// this is really just calling the super class attach object... 
// this is just nicer from a readability standpoint
-(void)attachArgument:(BBOSCArgument*)anArgument
{
	[self attachObject:anArgument];
}

// this is the main way in which you attach arguments to a message
// the order they are in the array is the order they get sent in the packet
// this is really just calling the super class attach object... 
// this is just nicer from a readability standpoint
-(void)attachArguments:(NSArray*)anArray
{
	[self attachObjects:anArray];
}

// generates an NSData object that holds the bytes in the OSC 
// specified format for this argument
-(NSData*)packetizedData
{
	// need to build up my packetized data block out of my address and my arguments
	// general format:
	// address typeTagString arg1 arg2 ... argn
	
	// first, check to see if we have an 'easy' case
	if ([containedObjects count] == 0) return [[self address] packetizedData];
	
	// ok, we are here so we have at least one arg, possibly more
	//make a container to store it all in, start with the address
	NSMutableData * packetData = [NSMutableData dataWithData:[[self address] packetizedData]];
	
	// now tack on the type tag string
	[packetData appendData:[BBOSCDataUtilities dataBlockFromString:[self typeTagString]]];

	// now add on all the arguments
	for (BBOSCArgument * anArg in containedObjects) {
		[packetData appendData:[anArg packetizedData]];
	}
	// that's it!
	return packetData;
}

// the type string is not stored, we just generate it when we need it
-(NSString*)typeTagString
{
	NSMutableString * tagString = [NSMutableString string];
	[tagString appendString:@","]; // start with the 'magic' comma
	
	// now iterate across all my arguments and get all the types
	for (BBOSCArgument * anArg in containedObjects) {
		[tagString appendFormat:@"%c",[anArg type]];
	}
	return tagString;
}

// this is really just for debugging and logging purposes
// it is a handy way to look at your message data
-(NSString*)stringRepresentation
{
	NSMutableString * stringRep = [NSMutableString string];
	[stringRep appendString:@"MESSAGE:\naddress:"];
	[stringRep appendString:[[self address] address]];
	[stringRep appendString:@"\n types:"];
	[stringRep appendString:[self typeTagString]];
	
	// now iterate across all my arguments and get all the types
	for (BBOSCArgument * anArg in containedObjects) {
		[stringRep appendFormat:@"\n%@",anArg];
	}
	return stringRep;
}

// your basic dealloc
- (void) dealloc
{
	[address release];
	[super dealloc];
}


@end
