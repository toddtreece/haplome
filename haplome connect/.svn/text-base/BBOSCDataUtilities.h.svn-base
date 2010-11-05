//
//  BBOSCDataUtilities.h
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

// the dataUtilities deal with the argument-level of the bit stream. 
// the datautilities dont know anything about the structure of the 
// OSC stream beyond that.
// all the ugly bit-level code is stored here
// these methods are all here so that the bit-level formatting is all in one place.
// also, all the non obj-C ish code is here as well (ie the c-style arrays and bit-shifting and uglyness)
// also note, this object is never instantiated, it is just a class with a bunch of helper methods

@interface BBOSCDataUtilities : NSObject {

}

+ (NSData*)blobFromDataBlock:(NSData*)someData;
+ (NSData*)dataBlockFromBlob:(NSData*)someData;
+ (NSData*)dataBlockFromFloat:(float)aFloat;
+ (NSData*)dataBlockFromInt:(int)anInt;
+ (NSData*)dataBlockFromString:(NSString*)aString;
+ (NSData*)dataBlockFromUInt:(unsigned int)anInt;
+ (NSData*)ntpTimestampForImmediate;
+ (NSData*)ntpTimestampFromNSDate:(NSDate*)aDate;
+ (NSData*)paddedDataFromData:(NSData*)someData;
+ (NSDate*)dateFromNTPTimestamp:(NSData*)someData;
+ (NSString*)stringFromDataBlock:(NSData*)someData;
+ (float)floatFromDataBlock:(NSData*)someData;
+ (int)intFromDataBlock:(NSData*)someData;
+ (unsigned int)uIntFromDataBlock:(NSData*)someData;

// 14 methods




@end
