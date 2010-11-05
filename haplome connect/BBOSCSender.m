//
//  BBOSCSender.m
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

#import "BBOSCSender.h"

#import "BBOSCPacket.h"

@implementation BBOSCSender

/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////

// the quick way to get a nice auto-released sender
+(BBOSCSender*)senderWithDestinationHostName:(NSString*)aName portNumber:(int)aPortNumber
{
	BBOSCSender * newSender = [[BBOSCSender alloc] initWithDestinationHostName:aName portNumber:aPortNumber]; 
	return [newSender autorelease];
}


/////////////////////////////////////////////////////////////////
// INSTANCE METHODS
/////////////////////////////////////////////////////////////////
// the preferred init, pretty simple really
// set the instance variables and get the socket ready
- (id) initWithDestinationHostName:(NSString*)aName portNumber:(int)aPortNumber  
{
	self = [super init];
	if (self != nil) {
		[self setValue:aName forKey:@"destinationHostName"];
		portNumber = aPortNumber;
		if (![self prepareSocket]) return nil;
	}
	return self;
}


// this mearly prepares the outbound socket on our end.
// the actual connection and all that happens when we send something
-(BOOL)prepareSocket
{
	// ask the system for a nice socket 
	if ((socketDescriptor = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket");
		return NO;
	}
	
	// prepare the destination address structure that we will be using 
	struct hostent * he = gethostbyname([destinationHostName cStringUsingEncoding:NSASCIIStringEncoding]); 
	
	// some ugly POSIX socket code stuff:
	destinationAddress.sin_family = AF_INET;   // set the family, which is just about always this
	destinationAddress.sin_port = htons(portNumber); // set the destination port number, in network short order
	destinationAddress.sin_addr = *((struct in_addr *)he->h_addr);	// set the dest addy, which we get from converting another ugly struct into this one
	// set the zeros (which is basically a byte-placeholder so that this struct can be freely substituted for an older crappier
	// structure that was used in the dark ages of socket programming
	memset(destinationAddress.sin_zero, '\0', sizeof destinationAddress.sin_zero);

	return YES;
}

// Here it is, the main event:
// we are using sendto instead of send because this is an 'unconnected' socket.
// basically this means we make a temporary connection every time we send a packet
// (this is often how UDP goes) if we cared, we would be listening for an ACK back
// from our server, but we dont because this is OSC, and we will send another
// packet soon enough
-(BOOL)sendOSCPacket:(BBOSCPacket*)aPacket
{
	// get the 'raw' data
	NSData * packetData = [aPacket packetizedData];

	int numbytes;	
	// TODO: make this handle the numbytes underrunning
	// numbytes is the number of bytes that actually got sent.  this may be less than the number of bytes that you want to be sent
	// this rarely happens in this day and age, what with the big buffers and all that. however, for a complete robust
	// implementation this should be handled better...
	if ((numbytes = sendto(socketDescriptor, [packetData bytes], [packetData length], 0, (struct sockaddr *)&destinationAddress, sizeof destinationAddress)) == -1) {
		perror("sendto");
		return NO;
	}
	return YES;	
}

- (void) dealloc
{
	// let go of this socket
	close(socketDescriptor);
	[destinationHostName release];
	[super dealloc];
}

@end
