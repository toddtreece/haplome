//
//  AppDelegate_iPhone.m
//  __                        ___                                       
// /\ \                      /\_ \                                      
// \ \ \___      __     _____\//\ \     ___    ___ ___      __          
//  \ \  _ `\  /'__`\  /\ '__`\\ \ \   / __`\/' __` __`\  /'__`\        
//   \ \ \ \ \/\ \L\.\_\ \ \L\ \\_\ \_/\ \L\ \\ \/\ \/\ \/\  __/        
//    \ \_\ \_\ \__/.\_\\ \ ,__//\____\ \____/ \_\ \_\ \_\ \____\       
//     \/_/\/_/\/__/\/_/ \ \ \/ \/____/\/___/ \/_/\/_/\/_/\/____/       
//                        \ \_\                                         
//                         \/_/
// haplome
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Todd Treece on 11/2/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "Reachability.h"
#import "MainViewController.h"
#import "NSObject+DDExtensions.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define kHaplomeIdentifier		@"haplome"


@implementation AppDelegate_iPhone
@synthesize oscPrefix;
@synthesize inPort;
@synthesize outPort;
@synthesize manager;
@synthesize window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self setupDefaults];
	[self setupListeners];
	mainViewController = [MainViewController alloc];
	[window addSubview:mainViewController.view];
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)setupListeners{
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
	self.manager = [[OSCManager alloc] init];
	[self.manager setDelegate:self];
	self.inPort = [self.manager createNewInputForPort:4321 withLabel:@"haplome"];
}

- (void)setupDefaults {
	self.oscPrefix = @"/mlr";
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"xval_pref"] != nil) {
		xNumPads = [[[NSUserDefaults standardUserDefaults] stringForKey:@"xval_pref"] intValue];
	} else {
		xNumPads=8;
	}
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"yval_pref"] != nil) {
		yNumPads = [[[NSUserDefaults standardUserDefaults] stringForKey:@"yval_pref"] intValue];
	} else {
		yNumPads=8;
	}
}

- (void) receivedOSCMessage:(OSCMessage *)m {
	//NSLog(@"%s ... %@",__func__,m);
	NSString *addy = [m address];
	if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/led/set"]]]) {
		[self receivedLed:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/led/col"]]]) {
		[self receivedCol:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/led/row"]]]) {
		[self receivedRow:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/led/map"]]]) {
		[self receivedFrame:m];
	}else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/led/all"]]]) {
		[self receivedAll:m];
	} else if ([addy isEqualToString:@"/sys/info"]) {
		[self receivedInfo:m];
	} else if ([addy isEqualToString:@"/sys/prefix"]) {
		[self receivedPrefix:m];
	} else if ([addy isEqualToString:@"/sys/port"]) {
		[self receivedPort:m];
	}
}

-(void)receivedPrefix:(OSCMessage *)message {
	self.oscPrefix = [[message value] stringValue];
    
    OSCMessage *newMsg = [OSCMessage createWithAddress:@"/sys/prefix"];
	[newMsg addString:self.oscPrefix];
	[self.outPort sendThisMessage:newMsg];
}

-(void)receivedPort:(OSCMessage *)message {

	port = [[message value] intValue];
    [self.manager createNewInputForPort:port withLabel:@"haplome"];
    self.outPort = [self.manager createNewOutputToAddress:[inPort remoteAddress] atPort:port];
    
    OSCMessage *newMsg = [OSCMessage createWithAddress:@"/sys/port"];
	[newMsg addInt:port];
	[self.outPort sendThisMessage:newMsg];
}

-(void)receivedInfo:(OSCMessage *)message {
    
    OSCMessage *newMsg = [OSCMessage createWithAddress:@"/sys/id"];
	[newMsg addString:@"m0000666"];
	[self.outPort sendThisMessage:newMsg];
    
    newMsg = [OSCMessage createWithAddress:@"/sys/prefix"];
	[newMsg addString:self.oscPrefix];
	[self.outPort sendThisMessage:newMsg];
    
	newMsg = [OSCMessage createWithAddress:@"/sys/port"];
	[newMsg addInt:port];
	[self.outPort sendThisMessage:newMsg];
    
    newMsg = [OSCMessage createWithAddress:@"/sys/host"];
	[newMsg addString:[self getIPAddress]];
	[self.outPort sendThisMessage:newMsg];

	newMsg = [OSCMessage createWithAddress:@"/sys/size"];
	[newMsg addInt:xNumPads];
    [newMsg addInt:yNumPads];
	[self.outPort sendThisMessage:newMsg];
    
    newMsg = [OSCMessage createWithAddress:@"/sys/rotation"];
	[newMsg addInt:0];
	[self.outPort sendThisMessage:newMsg];

}

- (void) receivedLed:(OSCMessage *)message {
	int colVal = [[[message valueArray] objectAtIndex:0] intValue];
	int rowVal = [[[message valueArray] objectAtIndex:1] intValue];
	int command = [[[message valueArray] objectAtIndex:2] intValue];
	if(command == 1) {
		if(colVal < yNumPads && rowVal < xNumPads){
			[[mainViewController dd_invokeOnMainThread] lightOn:rowVal withCol:colVal];
		}
	} else if(command == 0) {
		if(colVal < yNumPads && rowVal < xNumPads){
			[[mainViewController dd_invokeOnMainThread] lightOff:rowVal withCol:colVal];
		}
	}
}

- (void) receivedAll:(OSCMessage *)message {
	NSUInteger x,y;
	int command = [[message value] intValue];
	if(command == 1) {
		for(y = 0; y < yNumPads; ++y) {
			for(x = 0; x < xNumPads; ++x) {
				[[mainViewController dd_invokeOnMainThread] lightOn:x withCol:y];
			}
		}
	} else if(command == 0) {
		for(y = 0; y < yNumPads; ++y) {
			for(x = 0; x < xNumPads; ++x) {
				[[mainViewController dd_invokeOnMainThread] lightOff:x withCol:y];
			}
		}
	}
}
				
- (void) receivedRow:(OSCMessage *)message {
	int toggleValue, i;
	int rowVal = [[[message valueArray] objectAtIndex:1] intValue];
	NSString *colBinary = [self getBinary:[[[message valueArray] objectAtIndex:2] intValue]];
	NSString *col2Binary;
	if([message valueCount] > 3){
		col2Binary = [self getBinary:[[[message valueArray] objectAtIndex:3] intValue]];
	}
	for(i=0; i < xNumPads; ++i) {
		if(i < 8){
			toggleValue = [self getIntFromString:colBinary atLocation:i];
		} else if (i > 7) {
			if([message valueCount] > 3) {
				toggleValue = [self getIntFromString:col2Binary atLocation:i - 8];
			}
		}
		if(toggleValue == 1) {
			if(rowVal < xNumPads && i < yNumPads){
				[[mainViewController dd_invokeOnMainThread] lightOn:rowVal withCol:i];
			}				
		} else if (toggleValue == 0) {
			if(rowVal < xNumPads && i < yNumPads){
				[[mainViewController dd_invokeOnMainThread] lightOff:rowVal withCol:i];
			}
		}
	}
}

- (void) receivedCol:(OSCMessage *)message {
	int toggleValue, i;
	int colVal = [[[message valueArray] objectAtIndex:0] intValue];
	NSString *rowBinary = [self getBinary:[[[message valueArray] objectAtIndex:2] intValue]];
	NSString *row2Binary;
	if([message valueCount] > 3){
		row2Binary = [self getBinary:[[[message valueArray] objectAtIndex:3] intValue]];
	}
	for(i=0; i < yNumPads; ++i) {
		if(i < 8){
			toggleValue = [self getIntFromString:rowBinary atLocation:i];
		} else if (i > 7) {
			if([message valueCount] > 3) {
				toggleValue = [self getIntFromString:row2Binary atLocation:i - 8];
			}
		}
		if(toggleValue == 1) {
			if(colVal < yNumPads && i < xNumPads){
				[[mainViewController dd_invokeOnMainThread] lightOn:i withCol:colVal];
			}				
		} else if (toggleValue == 0) {			
			if(colVal < yNumPads && i < xNumPads){
				[[mainViewController dd_invokeOnMainThread] lightOff:i withCol:colVal];
			}
		}
	}
}

- (void) receivedFrame:(OSCMessage *)message {
	int toggleValue, i;
	int rowVal;
	NSString *colBinary;
    // start at 2 since the first two values are offsets
	for (rowVal = 2; rowVal < 10; ++rowVal) {
		colBinary = [self getBinary:[[[message valueArray] objectAtIndex:rowVal] intValue]];
		for(i=0; i < 8; ++i) {
			toggleValue = [self getIntFromString:colBinary atLocation:i];
			if(toggleValue == 1) {
				if(rowVal < 10 && i < 8){
					[[mainViewController dd_invokeOnMainThread] lightOn:(rowVal - 2) withCol:i];
				}				
			} else if (toggleValue == 0) {			
				if(rowVal < 10 && i < 8){
					[[mainViewController dd_invokeOnMainThread] lightOff:(rowVal - 2) withCol:i];
				}
			}
		}
	}
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach {
	if(curReach == wifiReach) {	
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if (netStatus == NotReachable){
			[self _showAlert:@"WiFi Access Not Available. Visit http://unionbridge.org/haplome for support."];
		}		
	} else {
		[self _showAlert:@"WiFi Access Not Available. Visit http://unionbridge.org/haplome for support."];
	}
}

- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void) _showAlert:(NSString*)title {
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:title delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(NSString *)getBinary:(int)sentNum {
	NSMutableString *str = [NSMutableString stringWithString:@""];
	for(NSInteger numberCopy = sentNum; numberCopy > 0; numberCopy >>= 1) {
		[str appendString:((numberCopy & 1) ? @"1" : @"0")];
	}
	int strlength = [str length];
	if (strlength < 8) {
		for (strlength; strlength < 8; ++strlength) {
			[str appendString:@"0"];
		}
	}
	return [NSString stringWithString: str];
}
                                            
-(NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

-(int)getIntFromString:(NSString *)theString atLocation:(int)theLocation {
	NSRange theRange = {theLocation, 1};
	return [[theString substringWithRange:theRange] intValue];
}

- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y {
	OSCMessage *newMsg = [OSCMessage createWithAddress:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/key"]]];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:1];
	[self.outPort sendThisMessage:newMsg];
	[mainViewController setLedState:YES atRow:x atCol:y];
}

- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y {
	OSCMessage *newMsg = [OSCMessage createWithAddress:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/grid/key"]]];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:0];
	[self.outPort sendThisMessage:newMsg];
	[mainViewController setLedState:NO atRow:x atCol:y];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[manager release];
    [inPort release];
	[outPort release];
	[mainViewController release];
	[oscPrefix release];
    [window release];
    [super dealloc];
}

@end


