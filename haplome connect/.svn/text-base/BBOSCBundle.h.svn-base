//
//  BBOSCBundle.h
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

// bundles hold a bunch of timestamped messages
// they can also hold other bundles

// bundles are meant to be immutable, with the exception of the timestamp (ie you can keep a standard bundle
// around and re-send it with a new timestamp instead of rebuilding it over and over again)


@interface BBOSCBundle : BBOSCPacket {
	NSDate * timeStamp;
}

@property (retain) NSDate* timeStamp;

+ (BBOSCBundle*)bundleWithTimestamp:(NSDate*)aDate;
- (NSData*)packetizedData;
- (NSString*)stringRepresentation;

// 3 methods


@end
