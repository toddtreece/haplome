//
//  BBOSCPacket.h
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

// this is a generic container for OSC data grams
// it is meant to be an abstract class

@interface BBOSCPacket : NSObject {
	NSMutableArray * containedObjects; // a generic container
}

- (NSData*)packetizedData;
- (NSString*)stringRepresentation;
- (void)attachObject:(id)anObject;
- (void)attachObjects:(NSArray*)anArray;
- (NSArray*)attachedObjects;

// 4 methods


@end
