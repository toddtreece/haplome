//
//  BBOSCDecoder.h
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

#import <Foundation/Foundation.h>

// this is an object that takes raw packets and gives back osc messages or osc bundles
// it is similar to the BBOSCDataUtilities except that this object knows about the structure of 
// the bundles and messages

// there are some similar methods in both objects, but they are subtly different, which is why
// these ones get their own object (to avoid confusion). just remember, the ones in the decoder
// 'understand' the packet structure, and the ones in the data utils only understand the data structure

@class BBOSCArgument;
@class BBOSCBundle;
@class BBOSCMessage;


@interface BBOSCDecoder : NSObject {

}

+ (BBOSCArgument*)argumentFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex ofType:(char)type;
+ (BBOSCBundle*)decodeRawBundle:(NSData*) someData;
+ (BBOSCMessage*)decodeRawMessage:(NSData*)someData;
+ (NSData*)dataBlobFromData:(NSData*)someData startingAt:(int)startIndex endingAt:(int*)endIndex;
+ (NSString*)stringFromData:(NSData*)someData startingAt:(int)dataIndex endingAt:(int*)endIndex;
+ (float)floatFromData:(NSData*)someData startingAt:(int)dataIndex endingAt:(int*)endIndex;
+ (id)decodeData:(NSData*)rawData;
+ (int)intFromData:(NSData*)someData startingAt:(int)dataIndex endingAt:(int*)endIndex;

// 8 methods



@end
