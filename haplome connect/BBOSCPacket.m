//
//  BBOSCPacket.m
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

#import "BBOSCPacket.h"

// TODO: add packet source information (in case of required response)

@implementation BBOSCPacket
// attach a message or another bundle to this bundle
-(void)attachObject:(id)anObject
{
	[self attachObjects:[NSArray arrayWithObject:anObject]];
}

// this is the preferred method for adding new messages or bundles.
-(void)attachObjects:(NSArray*)anArray
{
	if (containedObjects == nil) containedObjects = [[NSMutableArray alloc] init];
	[containedObjects addObjectsFromArray:anArray];	
}

-(NSArray*)attachedObjects
{
	return containedObjects;
}

// this is an abstract method
-(NSData*)packetizedData
{
	return nil;
}

-(NSString*)stringRepresentation
{
	return @"abstract parent class: BBOSCPacket";
}

- (void) dealloc
{
	[containedObjects release];
	[super dealloc];
}

@end
