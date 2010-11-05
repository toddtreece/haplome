//
//  BBOSCSender.h
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
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

// this is for sending OSC packets to another machine/process/whatever
// the default implementation uses unconnected UDP communication (which is about as simple as it gets)
// also, this object is meant to be Immutable, so if you need to connect to another host or another port,
// make a new sender object
// here is some sample code:
/*
 // this uses the convenience constructor for autoreleased objects
 [self setOscSender:[BBOSCSender senderWithDestinationHostName:@"localhost" portNumber:4556]];
 
 // you could also go the alloc-init route if you want a retained object
 BBOSCSender * myNewSender = [[BBOSCSender alloc] initWithDestinationHostName:@"127.0.0.1" portNumber:4556];
 
 // sending messages is very easy
 if (![[myNewSender sendOSCPacket:theMessage]) {
   NSLog(@"Oh Noes!!");
 }
*/


@class BBOSCPacket;

@interface BBOSCSender : NSObject {
	int socketDescriptor;
	int portNumber;
	NSString * destinationHostName;
	struct sockaddr_in destinationAddress; 
}

+ (BBOSCSender*)senderWithDestinationHostName:(NSString*)aName portNumber:(int)aPortNumber;
- (BOOL)prepareSocket;
- (BOOL)sendOSCPacket:(BBOSCPacket*)aPacket;
- (id) initWithDestinationHostName:(NSString*)aName portNumber:(int)aPortNumber  ;
- (void) dealloc;

// 5 methods



@end
