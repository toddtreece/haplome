//
//  BBOSCListener.h
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

// this is used if you are implementing a server system
// it starts listening on a certain port and generates dispatches 
// if any UDP packets arrive
// uses a delegate to dispatch the messages
// subclass this object if you want to use a different transport (ie TCP/IP or serial or whatever)
// sample code:
/*
 // the easiest way to get a listener, this will give you an 
 // autoreleaed object, so retain it if you want to keep it
 // this also sets a default delegate which is a BBOSCDispatcher object
 BBOSCListener * newListener = [BBOSCListener defaultListenerOnPort:4556];
 
 // otherwise use the alloc/init
 // and set the delegate and port manually
 BBOSCListener * newListener = [[BBOSCListener alloc] init];
 [newListener setDelegate:myDispatchDelegate];
 [newListener startListeningOnPort:4556];
 
*/

 // note the delegate needs to implent only a single method:
 // -(void)dispatchRawPacket:(NSData*)someData



@interface BBOSCListener : NSObject {
	int socketDescriptor;
	id delegate;
}

@property (retain) id delegate;

+ (BBOSCListener*)defaultListenerOnPort:(int)portNum;
- (void) dealloc;
- (void)listenThread:(id)sender;
- (void)startListeningOnPort:(int)portNum;
- (void)stopListening;

// 5 methods



@end
