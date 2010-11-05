//
//  BBOSCDataUtilities.m
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

#import "BBOSCDataUtilities.h"

#define BB_SECONDS_FROM_NTPEPOC_TO_REFDATE 1543503872
#define BB_TWO_TO_32 4294967296

@implementation BBOSCDataUtilities

////////////////////////////////////////////////////////////////////////////////////
// Data Block methods:
// they all generate a properly encoded, properly sized data block
// from the supplied type of data


+(NSData*)dataBlockFromInt:(int)anInt
{
	// we want to guarantee a 32 bit (4 byte) number
	// se we will do some bit shifting
	// this could be done in a loop, but this is far more readable
	unsigned char bytes[4];
	bytes[0] = anInt >> 24;
	bytes[1] = anInt >> 16;
	bytes[2] = anInt >> 8;
	bytes[3] = anInt;
	return [NSData dataWithBytes:bytes length:4];
}

// same as datablock from int, but with the unsigned int instead,
// this is used basically just for NTP timestamps
+(NSData*)dataBlockFromUInt:(unsigned int)anInt
{
	// basically the same as from Int, but with unsigned! 
	unsigned char bytes[4];
	bytes[0] = anInt >> 24;
	bytes[1] = anInt >> 16;
	bytes[2] = anInt >> 8;
	bytes[3] = anInt;
	return [NSData dataWithBytes:bytes length:4];
}

// generate a raw data block from an nsstring
+(NSData*)dataBlockFromString:(NSString*)aString
{
	NSData * stringData = [aString dataUsingEncoding:NSASCIIStringEncoding];
	// return a padded version
	return [BBOSCDataUtilities paddedDataFromData:stringData];
}

// generate a 4-byte ieee 754 float 
+(NSData*)dataBlockFromFloat:(float)aFloat
{
	NSSwappedFloat swapFloat = NSSwapHostFloatToBig(aFloat);
	// now convert that to a network ordered long
	long networkLong = htonl(swapFloat.v);
	
	// now break it into it's component bytes for data storage
	unsigned char fbytes[4];
	fbytes[0] = networkLong >> 24;
	fbytes[1] = networkLong >> 16;
	fbytes[2] = networkLong >> 8;
	fbytes[3] = networkLong;	
	return [NSData dataWithBytes:fbytes length:4];
}

// make a data block from a binay blob (which is also an nsdata)
+(NSData*)dataBlockFromBlob:(NSData*)someData
{
	// first, set the first 4 bytes to the size of the blob
	NSMutableData * blobData = [NSMutableData dataWithData:[BBOSCDataUtilities dataBlockFromInt:[someData length]]];
	// now we append the actual blob data
	[blobData appendData:someData];
	
	// return a padded version
	return [BBOSCDataUtilities paddedDataFromData:blobData];
}

// the takes the supplied data and generates a new data object that
// conforms to the 4-byte chunk requirements
+(NSData*)paddedDataFromData:(NSData*)someData
{
	NSMutableData * paddedData = [NSMutableData dataWithData:someData];
	int underFlow = 4 - ([paddedData length] % 4);
	if (underFlow > 0) {
		// need to pad out with 0's
		char padding[] = { 0,0,0,0 }; // TODO: make this a constant
		[paddedData appendBytes:padding length:underFlow];
	}
	return paddedData;
}


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////
// Methods to extract data from 'data blocks' (ie data in 'packet' format from the network)
//
//
//

// this will pull out an int value from the first 4 bytes of the provided data block
// the data block should be in 'packet' format (if you want the int to mean anything)
+(int)intFromDataBlock:(NSData*)someData
{
	if ([someData length] < 4) return 0; // TODO throw an exception
	unsigned char * bytes = (unsigned char *)[someData bytes];
	int argValue = 0;
	argValue += bytes[0] << 24;
	argValue += bytes[1] << 16;
	argValue += bytes[2] << 8;
	argValue += bytes[3] ;
	return argValue;
}

// same as int, but with unsigned types
+(unsigned int)uIntFromDataBlock:(NSData*)someData
{
	if ([someData length] < 4) return 0; // TODO throw an exception
	unsigned char * bytes = (unsigned char *)[someData bytes];
	unsigned int argValue = 0;
	argValue += bytes[0] << 24;
	argValue += bytes[1] << 16;
	argValue += bytes[2] << 8;
	argValue += bytes[3] ;
	return argValue;
}

// grab a string out of the supplied data, use ASCII encoding as per the spec
// also, this will strip off any 0 padding
+(NSString*)stringFromDataBlock:(NSData*)someData
{
	NSString * argValue = [[[NSString alloc] initWithData:someData encoding:NSASCIIStringEncoding] autorelease];
	// strip off any trailing \0's
	return [argValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\0"]];	
}

// rebuild the float value from the ieee 754 4 byte chunk
+(float)floatFromDataBlock:(NSData*)someData
{
	if ([someData length] < 4) return 0; // TODO throw an exception
	unsigned char * bytes = (unsigned char *)[someData bytes];
	long argValue = 0;
	argValue += bytes[0] << 24;
	argValue += bytes[1] << 16;
	argValue += bytes[2] << 8;
	argValue += bytes[3] ;
	NSSwappedFloat swap;
	swap.v = ntohl(argValue);
	float f = NSSwapBigFloatToHost(swap);
	return f;
}

// retrieve the binary data from this block
// uses the first 4 byte chunk as the length, so be sure to include that
+(NSData*)blobFromDataBlock:(NSData*)someData
{
	// extract the binary blob from the rest
	int size = [BBOSCDataUtilities intFromDataBlock:someData];
	// check to make sure the data block is big enough
	if ([someData length] < 4 + size) return nil; //TODO throw exception here
	// now pull out the bits we care about (ie the stuff between the size bytes and the padding 0's)
	NSData * blob = [someData subdataWithRange:NSMakeRange(4, size)];
	return blob;
}


/////////////////////////////////////////////////////////
// timestamps
//////////////////////////////////////////////////////////

// a convenience method to generate 'now' timestamps
+(NSData*)ntpTimestampForImmediate
{
	NSMutableData* ntpData = [NSMutableData dataWithData:[BBOSCDataUtilities dataBlockFromInt:0]];
	[ntpData appendData:[BBOSCDataUtilities dataBlockFromInt:1]];
	return ntpData;	
}

// the generic timestamp from date method
+(NSData*)ntpTimestampFromNSDate:(NSDate*)aDate
{
	// the OSC spec says that the reference date for timestamps is
	// the NTP Epoc, and is set for
	// jan 1, 1900.  the Cocoa ref date is jan 1 2001, so we will have to add on
	// all those seconds every time...
	
	// this is the whole number of seconds from the system Epoch
	int seconds = trunc([aDate timeIntervalSinceReferenceDate]);
	
	// now we get the fractional seconds
	double fractional = [aDate timeIntervalSinceReferenceDate] - seconds;
	// now bump up the seconds so that they are from the NTP epoch
	seconds += BB_SECONDS_FROM_NTPEPOC_TO_REFDATE;
	
	// now we need to figure out how many slices of 2^-32 seconds equal our fractional time
	// which is pretty easy really, since we have a value like 0.12345
	// we can just multiply it out: value * 2^32
	unsigned int fractionalInteger = (unsigned int)(fractional * BB_TWO_TO_32);
	
	// great! now we have both bits of the NTP puzzle, we just need to jam them into a datastream
	NSMutableData* ntpData = [NSMutableData dataWithData:[BBOSCDataUtilities dataBlockFromInt:seconds]];
	[ntpData appendData:[BBOSCDataUtilities dataBlockFromUInt:fractionalInteger]];
	return ntpData;
}

// reverse the NTP timestamp and get a nice cocoa-y NSDate
+(NSDate*)dateFromNTPTimestamp:(NSData*)someData
{
	// grabs the top 8 bytes form this data and generates an NSDate from it
	int seconds = [BBOSCDataUtilities intFromDataBlock:someData];
	unsigned int fractional = [BBOSCDataUtilities uIntFromDataBlock:[someData subdataWithRange:NSMakeRange(4, 4)]];
	
	if ((seconds == 0) && (fractional == 1)) return [NSDate distantPast]; // the RIGHT NOW button
	
	seconds -= BB_SECONDS_FROM_NTPEPOC_TO_REFDATE; // now it is relative to the system ref date
	double nonIntegerStuff = fractional / BB_TWO_TO_32; //reverse the fractional packing
	
	return [NSDate dateWithTimeIntervalSinceReferenceDate:(seconds + nonIntegerStuff)];
}





@end
