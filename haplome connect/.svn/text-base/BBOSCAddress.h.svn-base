//
//  BBOSCAddress.h
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

// this is the address portion of the message, it is used to identify where the
// message gets dispatched to on the server side.
// most addresses look like one of these:
// /component/method
// /component/componentNumber/method 
// /a/b/c/s/e/f/s/g/h/t 
// and so on.  basically like a directory structure

@interface BBOSCAddress : NSObject {
	NSString * address;
}

@property (copy) NSString* address;

+ (BBOSCAddress*)addressWithArray:(NSArray*)addressArray;
+ (BBOSCAddress*)addressWithString:(NSString*)addressString;
- (NSData*)packetizedData;
- (id) initWithString:(NSString*)aString;

// 4 methods


@end
