//
//  BBOSCArgument.h
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

#import <Foundation/Foundation.h>

// this is probably the most complicated object of all the OSC objects, but only because
// it needs to handle so many different data types

// currently it supports:
// int
// float
// string
// data (blob)

// which is in line with the OSC 1.0 spec
// NOTE: this class is meant to be immutable, ie initWith<sometype> and then 
// use it like an NSNumber

// if you want to add more argument types, start here
// (then go to the decoder)

@interface BBOSCArgument : NSObject {
	char type;
	NSData * data;
}

@property (retain) NSData* data;
@property (assign) char type;

+ (BBOSCArgument*)argumentWithDataBlob:(NSData*)someData;
+ (BBOSCArgument*)argumentWithFloat:(float)aFloat;
+ (BBOSCArgument*)argumentWithInt:(int)anInt;
+ (BBOSCArgument*)argumentWithString:(NSString*)aString;

- (NSData*)dataBlobValue;
- (NSData*)packetizedData;
- (NSString*)description;
- (NSString*)stringValue;
- (float)floatValue;
- (id) initWithDataBlob:(NSData*)someData;
- (id) initWithFloat:(float)aFloat;
- (id) initWithInt:(int)anInt;
- (id) initWithString:(NSString*)aString;
- (int)intValue;
- (void)setDataBlobValue:(NSData*)someData;
- (void)setFloatValue:(float)aFloat;
- (void)setIntValue:(int)anInt;
- (void)setStringValue:(NSString*)aString;

// 18 methods


@end
