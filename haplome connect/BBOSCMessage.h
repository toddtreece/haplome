//
//  BBOSCMessage.h
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
#import "BBOSCPacket.h"

// BBOSCMessage is the container object for OSC dispatch messages.
// at the simplest it contains just a BBOSCAddress (ie a dispatch that does not require
// an argument)
// at its most complicated, it can hold a number of various typed arguments in addition to the address

@class BBOSCAddress;
@class BBOSCArgument;

@interface BBOSCMessage : BBOSCPacket {
	BBOSCAddress * address; // the intended recipient of this message
}

@property (retain) BBOSCAddress* address;

+ (BBOSCMessage*)messageWithBBOSCAddress:(BBOSCAddress*)anAddress;
- (NSData*)packetizedData;
- (NSString*)stringRepresentation;
- (NSString*)typeTagString;
- (id) initWithBBOSCAddress:(BBOSCAddress*)anAddress;
- (void)attachArgument:(BBOSCArgument*)anArgument;
- (void)attachArguments:(NSArray*)anArray;

// 7 methods


@end
