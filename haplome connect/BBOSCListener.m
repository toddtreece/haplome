//
//  BBOSCListener.m
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

#import "BBOSCListener.h"
#import "BBOSCDispatcher.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define MAX_UDP_DATAGRAM_SIZE 65507

@implementation BBOSCListener

@synthesize delegate;

/////////////////////////////////////////////////////////////////
// CLASS METHODS
/////////////////////////////////////////////////////////////////
// the 'easy' button for listeners
// dont forget to retain this object when you get it
+(BBOSCListener*)defaultListenerOnPort:(int)portNum
{
	// make a enw listener, assign the delegate, and set the port. that is it
	BBOSCListener * listener = [[BBOSCListener alloc] init];
	[listener setDelegate:[[[BBOSCDispatcher alloc] init] autorelease]];
	[listener startListeningOnPort:portNum];	
	return [listener autorelease];
}


/////////////////////////////////////////////////////////////////
// INSTANCE METHODS
/////////////////////////////////////////////////////////////////

////
// here is some non-cocoa, so look away if you are C/POSIX averse
// however, it is a pretty straighforward method.
// opens a socket, attaches that socket to a port and starts to listen
-(void)startListeningOnPort:(int)portNum
{
	// set up some socket structs
	struct sockaddr_in my_addr;    // my address information

	// set up my buffer
	// get a socket form the system that i can listen on
	if ((socketDescriptor = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket");
		return;
	}
	
	// set up my_addr with the proper port number and IP addy
	my_addr.sin_family = AF_INET;         // host byte order
	my_addr.sin_port = htons(portNum);     // short, network byte order
	my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
	memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);
	
	// bind my socket with the proper info
	if (bind(socketDescriptor, (struct sockaddr *)&my_addr, sizeof my_addr) == -1) {
		perror("bind");
		return;
	}
	
	// start a thread for listening
	[NSThread detachNewThreadSelector: @selector(listenThread:) toTarget:self withObject:self];    
}


// the main thread for this object.
// basically it just sits and waits for stuff to come in
// when it does, then we hand it off to the delegat
-(void)listenThread:(id)sender
{
  NSAutoreleasePool *apool=[[NSAutoreleasePool alloc] init];
	struct sockaddr_in their_addr;
	int numbytes;
	char buf[MAX_UDP_DATAGRAM_SIZE];
	socklen_t addr_len;
	addr_len = sizeof their_addr;
  
  NS_DURING 
	while (socketDescriptor > 0) {
		// TODO: handle this error better than not at all
		// grab the raw bytes off the socket into a buffer
		if ((numbytes = recvfrom(socketDescriptor, buf, MAX_UDP_DATAGRAM_SIZE-1 , 0,
														 (struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
    }
		// make that buffer all cocoa-liscious inside an NSData object
		NSData * packetData = [NSData dataWithBytes:buf length:numbytes];
		// make sure the delegate can deal with it, and pass it on (pass it onto the main thread too)
		if ([[self delegate] respondsToSelector:@selector(dispatchRawPacket:)])
			[[self delegate] performSelectorOnMainThread:@selector(dispatchRawPacket:) withObject:packetData waitUntilDone:NO];
	} 
	NS_HANDLER
	// boring generic handler alert
	NSLog(@"error with listen thread %@",[localException reason]);
	// TODO: make this platform aware, ie iPhone has no NSAlert
//	[[NSAlert alertWithMessageText:@"Error with listenThread" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:[localException reason]] runModal];
	
	NS_ENDHANDLER
	[apool release];
}

// close up the socket so that it doesnt just hang for a few minutes after the app closes
-(void)stopListening
{
	close(socketDescriptor);
	// invalidate the socket descriptor as well, just in case someone tries to re-use this now closed socket
	socketDescriptor = -1;
}

- (void) dealloc
{
	if (socketDescriptor > 0) [self stopListening];
	[delegate release];
	[super dealloc];
}

@end
