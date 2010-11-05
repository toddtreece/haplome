//
//  BBOSCDecoder.m
//  BBOSC-Cocoa
//
//  Created by ben smith on 7/20/08.
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

#import "BBOSCDecoder.h"

#import "BBOSCDataUtilities.h"
#import "BBOSCAddress.h"
#import "BBOSCArgument.h"
#import "BBOSCMessage.h"
#import "BBOSCBundle.h"

@implementation BBOSCDecoder

/////////////////////////////////////////////
// general note: this class is kinda ugly, and need to be refactored
// TODO: refactor me

// this runs like a state machine.
// it runs through the data byte-by-byte and handles each byte depending
// on the state
+(id)decodeData:(NSData*)rawData
{
	// do a quick safety check
	if ([rawData length] == 0) return nil;
	
	unsigned char * bytes = (unsigned char *)[rawData bytes];
	// first i need to decode this packet
	if (bytes[0] == '#') {
		return [self decodeRawBundle:rawData];
	}
	return [self decodeRawMessage:rawData];
}


// basically we are going to recurse through the data structure, generating real objects from the
// data stream as we go
// NOTE: this must be called with a proper bundle packet, if not, it will give back 
// all sorts of junk data
+(BBOSCBundle*)decodeRawBundle:(NSData*) someData
{
	// keep track of wher ewe are in the supplied chunk of data
	int bundleIndex = 0;
	
	// make a new bundle object to store all the nady dandy info we are about to farm out of the data
	BBOSCBundle * newBundle = [[BBOSCBundle alloc] init];
	
	// the first chunk of data will be equal to "#bundle", so skip over it
	bundleIndex += 8; // the number of characters in "#bundle", plus one 0 pad
	// now we grab the next 8 bytes, which are the timestamp
	NSDate* timestamp = [BBOSCDataUtilities dateFromNTPTimestamp:[someData subdataWithRange:NSMakeRange(bundleIndex, 8)]];
	[newBundle setTimeStamp:timestamp];
	bundleIndex += 8; // move the index to the next byte after the timestamp

	
	// now we start to decode the substructures
	while (bundleIndex < ([someData length] - 1)) {
		// the next thing will be a 4-byte size
		int messageSize = [BBOSCDataUtilities intFromDataBlock:[someData subdataWithRange:NSMakeRange(bundleIndex, 4)]];
		bundleIndex += 4;
		BBOSCPacket * decodedStuff = [BBOSCDecoder decodeData:[someData subdataWithRange:NSMakeRange(bundleIndex, messageSize)]];
		[newBundle attachObject:decodedStuff];
		bundleIndex += messageSize;
	}
	return [newBundle autorelease];
}

// this one is a bit more complicated than the bundle since we will need to figure out the 
// arguments and all that stuff
+(BBOSCMessage*)decodeRawMessage:(NSData*)someData
{
	int startIndex = 0;
	int endIndex;
	
	// find the end of the address by looking for nulls in the stream
	NSString* addy = [BBOSCDecoder stringFromData:someData startingAt:startIndex endingAt:&endIndex];
	if (addy == nil) return nil;
	// increment our 'starting index' to just after the start string
	startIndex = endIndex;
	
	// the next in line is the type tag string, in the form of: ',iifs\0\0\0'  or something like it
	// do the same thing as above:
	NSString* typeTag = [BBOSCDecoder stringFromData:someData startingAt:startIndex endingAt:&endIndex];
	if (typeTag == nil) return nil;
	startIndex = endIndex;

	// now it gets a bit more interesting
	// use the type tage to get the types, and pull them out of the data stream one-by-one
	// check to make sure the type tag is proper
	if ([typeTag characterAtIndex:0] != ',') return nil;

	// now go through all the remaining data and build arguments out of it
	// the dataindex should be pointing at the first byte of the arguments
	// we will use to type tag as a 'table of contents' to our data packet
	// each arg we pull out will move the index of wher we are forward so 
	// we can get the next one
	NSMutableArray * args = [NSMutableArray array];
	int typeTagIndex = 1;
	while (typeTagIndex < [typeTag length]) {
		char type = [typeTag characterAtIndex:typeTagIndex];
		[args addObject:[BBOSCDecoder argumentFromData:someData startingAt:startIndex endingAt:&endIndex ofType:type]];
		startIndex = endIndex;
		typeTagIndex++;
	}
	
	// now we should have all the bits we need
	BBOSCMessage * newMessage = [BBOSCMessage messageWithBBOSCAddress:[BBOSCAddress addressWithString:addy]];
	[newMessage attachArguments:args];
	return newMessage;
}

// this is a convenience method that just routes the right type of data into the argument
+(BBOSCArgument*)argumentFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex ofType:(char)type
{
	// 4 type of args:
	// s -string
	// i - int
	// f - float
	// b - binary blob
	
	if (type == 's') {
		NSString * string = [BBOSCDecoder stringFromData:someData startingAt:startIndex endingAt:endIndex];
		return [BBOSCArgument argumentWithString:string];
	}

	if (type == 'i') {
		int argVal = [BBOSCDecoder intFromData:someData startingAt:startIndex endingAt:endIndex];
		return [BBOSCArgument argumentWithInt:argVal];
	}
	
	if (type == 'f') {
		float argVal = [BBOSCDecoder floatFromData:someData startingAt:startIndex endingAt:endIndex];
		return [BBOSCArgument argumentWithFloat:argVal];
	}
	
	if (type == 'b') {
		NSData* argVal = [BBOSCDecoder dataBlobFromData:someData startingAt:startIndex endingAt:endIndex];
		return [BBOSCArgument argumentWithDataBlob:argVal];
	}
	return nil;
}


////////////////////////
// argument methods
////////////////////////
// NOTE: all these methods alter the value of endIndex. this is so that
// the calling method knows how big the resulting chunk of data was
// even if the 'real' data is not as big (ie has had the padding stripped off)

+(NSString*)stringFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex
{
	// one of the few nice things about this format is that it is in 4-byte chunks, so 
	// we dont need to look at all the data, just every 4 bytes, specifically the last
	// byte of the 4 byte chunk, if it is 0 then we are done
	
	*endIndex = startIndex + 3; // we want to look at the last byte in the 4 byte chunk

	// look at the raw data in a nice arry 
	unsigned char * bytes = (unsigned char *)[someData bytes];
	
	while (*endIndex < [someData length]) {
		// check for 0, if we have a zero at the end of a byte-chunk then we are done
		if (bytes[*endIndex] == 0) {
			// build a tring from the data chunk we just discovered
			NSString * stringToReturn = [BBOSCDataUtilities stringFromDataBlock:[someData subdataWithRange:NSMakeRange(startIndex, ((*endIndex + 1) - startIndex))]];
			*endIndex += 1; // add one so that we are aligned with the start of the next block, instead of the end of the last
			return stringToReturn;
		}
		*endIndex += 4; // increment to teh end of the next block
	}	
	return nil;
}

// one of the simpler ones, except for the setting of the end index
+(NSData*)dataBlobFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex
{
	// this is fairly straightforward.  
	NSData* blob = [BBOSCDataUtilities blobFromDataBlock:[someData subdataWithRange:NSMakeRange(startIndex, [someData length] - startIndex)]];
	// now figure out the endindex
	// check the underflow, to see how much padding we had
	int underFlow = 4 - ([blob length] % 4);
	// now build the next end index: the final data length was the blob + padding + a 4-byte size block at the front
	*endIndex = startIndex + [blob length] + underFlow + 4; 
	return blob;
}

// we know how big this one is, so it is an easy grab out of the stream
+(int)intFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex
{
	int argVal = [BBOSCDataUtilities intFromDataBlock:[someData subdataWithRange:NSMakeRange(startIndex, 4)]];
	// now figure out the endindex
	*endIndex = startIndex + 4;
	return argVal;	
}

// we know how big this one is, so it is also an easy grab out of the stream
+(float)floatFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex
{
	float argVal = [BBOSCDataUtilities floatFromDataBlock:[someData subdataWithRange:NSMakeRange(startIndex, 4)]];
	// now figure out the endindex
	*endIndex = startIndex + 4;
	return argVal;	
}



@end
