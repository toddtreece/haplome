//
//  BBOSCDispatcher.m
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

#import "BBOSCDispatcher.h"

#import "BBOSCDecoder.h"

@implementation BBOSCDispatcher

// this is the main method for the dispatcher
// it's job is to turn the get a fully-formed bundle or message 
// from the decoder, then dispatch all the messages appropriately
// right now, it does nothing.
// TODO: Finish me!!
-(void)dispatchRawPacket:(NSData*)someData
{
	id decodedPacket = [BBOSCDecoder decodeData:someData];
	NSLog(@"DISPATCH: %@",[decodedPacket stringRepresentation]);
}


@end
