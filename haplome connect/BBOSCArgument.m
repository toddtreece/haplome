//
//  BBOSCArgument.m
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

#import "BBOSCArgument.h"

#import "BBOSCDataUtilities.h"

@implementation BBOSCArgument

// save some typing by synthesizing
@synthesize data;
@synthesize type;

/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////

// these are the 'easy' methods they return nice auto-released objects

+(BBOSCArgument*)argumentWithString:(NSString*)aString
{
	BBOSCArgument* newArg = [[BBOSCArgument alloc] initWithString:aString];
	return [newArg autorelease];
}

+(BBOSCArgument*)argumentWithInt:(int)anInt
{
	BBOSCArgument* newArg = [[BBOSCArgument alloc] initWithInt:anInt];
	return [newArg autorelease];
}

+(BBOSCArgument*)argumentWithFloat:(float)aFloat
{
	BBOSCArgument* newArg = [[BBOSCArgument alloc] initWithFloat:aFloat];
	return [newArg autorelease];
}


+(BBOSCArgument*)argumentWithDataBlob:(NSData*)someData
{
	BBOSCArgument* newArg = [[BBOSCArgument alloc] initWithDataBlob:someData];
	return [newArg autorelease];
}


/////////////////////////////////////////////////////////////////
// INSTANCE METHODS
/////////////////////////////////////////////////////////////////

// these are the alloc/init versions used by the easy methods above
- (id) initWithString:(NSString*)aString
{
	self = [super init];
	if (self != nil) {
		if (aString == nil) return nil;
		[self setStringValue:aString];
	}
	return self;
}

- (id) initWithInt:(int)anInt
{
	self = [super init];
	if (self != nil) {
		[self setIntValue:anInt];
	}
	return self;
}

- (id) initWithFloat:(float)aFloat
{
	self = [super init];
	if (self != nil) {
		[self setFloatValue:aFloat];
	}
	return self;
}

- (id) initWithDataBlob:(NSData*)someData
{
	self = [super init];
	if (self != nil) {
		[self setDataBlobValue:someData];
	}
	return self;
}

// this is the method that returns the 'raw' network data
// currently this is how the argument is stored in the instance, so 
// this is easy
-(NSData*)packetizedData
{
	return [self data];
}


///////////////////////////////////////////////////////////////////////////
// String Argument Type
// set the string value into the data
-(void)setStringValue:(NSString*)aString
{
	[self setType:'s'];
	[self setData:[BBOSCDataUtilities dataBlockFromString:aString]];
}

// get the string value back
// convert the internal data to an string
-(NSString*)stringValue
{
	return [BBOSCDataUtilities stringFromDataBlock:[self data]];
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// Int Argument Type
// set the int value into the data
// dont forget the endienness (ie big endian)
-(void)setIntValue:(int)anInt
{
	[self setType:'i'];
	[self setData:[BBOSCDataUtilities dataBlockFromInt:anInt]];
}

// convert the data back into a nice int
-(int)intValue
{
	return [BBOSCDataUtilities intFromDataBlock:[self data]];
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// Float Argument Type
// set the float value into the data
// dont forget the endienness (ie big endian)
-(void)setFloatValue:(float)aFloat
{
	[self setType:'f'];
	[self setData:[BBOSCDataUtilities dataBlockFromFloat:aFloat]];
}
		 
// convert the data back into a nice int
-(float)floatValue
{
	return [BBOSCDataUtilities floatFromDataBlock:[self data]];
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// Data (blob) Argument Type
// set the binary into the data
// dont forget to pad out the end of the blob
// to guarantee 4-byte chunks
-(void)setDataBlobValue:(NSData*)someData
{
	[self setType:'b'];
	// the first thing we do is attach the data length as a four-byte block
	// to the front
	NSMutableData * blobData = [NSMutableData dataWithData:[BBOSCDataUtilities dataBlockFromInt:[someData length]]];
	// now we append the actual blob data
	[blobData appendData:someData];

	// return a padded version
	[self setData:[BBOSCDataUtilities paddedDataFromData:blobData]];
}

-(NSData*)dataBlobValue
{
	return [BBOSCDataUtilities blobFromDataBlock:[self data]];
}

//
///////////////////////////////////////////////////////////////////////////


// this is mostly for debugging and logging
// it is a handy way to look into your arguments and see what they are
-(NSString*)description
{
	if (type == 's') return [NSString stringWithFormat:@"%c { %@ }",[self type],[self stringValue]];
	if (type == 'i') return [NSString stringWithFormat:@"%c { %d }",[self type],[self intValue]];
	if (type == 'f') return [NSString stringWithFormat:@"%c { %f }",[self type],[self floatValue]];
	if (type == 'b') return [NSString stringWithFormat:@"%c { %@ }",[self type],[self dataBlobValue]];
	return @"no arg value";
}

- (void) dealloc
{
	[data release];
	[super dealloc];
}


@end
