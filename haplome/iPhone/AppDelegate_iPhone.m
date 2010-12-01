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
#define kHaplomeIdentifier		@"haplome"


@implementation AppDelegate_iPhone
@synthesize oscPrefix;
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
	[self.manager createNewInputForPort:1234 withLabel:@"haplome"];
}

- (void)setupDefaults {
	self.oscPrefix = @"/howto";
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
	if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/led"]]]) {
		[self receivedLed:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/led_col"]]]) {
		[self receivedCol:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/led_row"]]]) {
		[self receivedRow:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/frame"]]]) {
		[self receivedFrame:m];
	}else if ([addy isEqualToString:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/clear"]]]) {
		[self receivedClear:m];
	} else if ([addy isEqualToString:@"/sys/connection"]) {
		[self receivedConnectionInfo:m];
	} else if ([addy isEqualToString:@"/sys/prefix"]) {
		[self receivedPrefix:m];
	}
}

-(void)receivedPrefix:(OSCMessage *)message {
	self.oscPrefix = [[message value] stringValue];
}

- (void) receivedConnectionInfo:(OSCMessage *)message {
	NSString *ipAddress = [[[message valueArray] objectAtIndex:0] stringValue];
	int portInfo = [[[message valueArray] objectAtIndex:1] intValue];
	self.outPort = [self.manager createNewOutputToAddress:ipAddress atPort:portInfo];
}

- (void) receivedLed:(OSCMessage *)message {
	int colVal = [[[message valueArray] objectAtIndex:0] intValue];
	int rowVal = [[[message valueArray] objectAtIndex:1] intValue];
	int command = [[[message valueArray] objectAtIndex:2] intValue];
	if(command == 1) {
		if(colVal < yNumPads && rowVal < xNumPads){
			[mainViewController lightOn:rowVal withCol:colVal];
		}
	} else if(command == 0) {
		if(colVal < yNumPads && rowVal < xNumPads){
			[mainViewController lightOff:rowVal withCol:colVal];
		}
	}
}

- (void) receivedClear:(OSCMessage *)message {
	NSUInteger x,y;
	int command = [[message value] intValue];
	if(command == 1) {
		for(y = 0; y < yNumPads; ++y) {
			for(x = 0; x < xNumPads; ++x) {
				[mainViewController lightOn:x withCol:y];
			}
		}
	} else if(command == 0) {
		for(y = 0; y < yNumPads; ++y) {
			for(x = 0; x < xNumPads; ++x) {
				[mainViewController lightOff:x withCol:y];
			}
		}
	}
}
				
- (void) receivedRow:(OSCMessage *)message {
	int toggleValue, i;
	int rowVal = [[[message valueArray] objectAtIndex:0] intValue];
	int colVal = [[[message valueArray] objectAtIndex:1] intValue];
	NSLog(@"%@",[self getBinary:colVal]);
	int colVal2;
	if([message valueCount] > 2){
		colVal2 = [[[message valueArray] objectAtIndex:2] intValue];
	}
	for(i=0; i < xNumPads; ++i) {
		if(i < 8){
			toggleValue = colVal % 2;
			colVal = colVal / 2;
		} else if (i > 7) {
			if([message valueCount] > 2){
				toggleValue = colVal2 % 2;
				colVal2 = colVal2 / 2;
			}
		}
		if(toggleValue == 1) {
			if(rowVal < xNumPads && i < yNumPads){
				[mainViewController lightOn:rowVal withCol:i];
			}				
		} else if (toggleValue == 0) {
			if(rowVal < xNumPads && i < yNumPads){
				[mainViewController lightOff:rowVal withCol:i];
			}
		}
	}
}

- (void) receivedCol:(OSCMessage *)message {
	int toggleValue, i;
	int colVal = [[[message valueArray] objectAtIndex:0] intValue];
	int rowVal = [[[message valueArray] objectAtIndex:1] intValue];
	int rowVal2;
	if([message valueCount] > 2){
		rowVal2 = [[[message valueArray] objectAtIndex:2] intValue];
	}
	for(i=0; i < yNumPads; ++i) {
		if(i < 8){
			toggleValue = rowVal % 2;
			rowVal = rowVal / 2;
		} else if (i > 7) {
			if([message valueCount] > 2){
				toggleValue = rowVal2 % 2;
				rowVal2 = rowVal2 / 2;
			}
		}
		if(toggleValue == 1) {
			if(colVal < yNumPads && i < xNumPads){
				[mainViewController lightOn:i withCol:colVal];
			}				
		} else if (toggleValue == 0) {			
			if(colVal < yNumPads && i < xNumPads){
				[mainViewController lightOff:i withCol:colVal];
			}
		}
	}
}

- (void) receivedFrame:(OSCMessage *)message {
	int toggleValue, i;
	int rowVal, colVal;
	for (rowVal = 0; rowVal < 8; ++rowVal) {
		colVal= [[[message valueArray] objectAtIndex:rowVal] intValue];
		for(i=0; i < 8; ++i) {
			toggleValue = colVal % 2;
			colVal = colVal / 2;
			
			if(toggleValue == 1) {
				if(colVal < 8 && i < 8){
					[mainViewController lightOn:rowVal withCol:i];
				}				
			} else if (toggleValue == 0) {			
				if(colVal < 8 && i < 8){
					[mainViewController lightOff:rowVal withCol:i];
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

- (void) _showAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:title delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(NSString *)getBinary:(int)sentNum {
	NSMutableString *str = [NSMutableString stringWithString:@""];
	for(NSInteger numberCopy = sentNum; numberCopy > 0; numberCopy >>= 1) {
		[str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
	}
	int strlength = [str length];
	if (strlength < 8) {
		for (strlength; strlength < 8; ++strlength) {
			[str insertString:@"0" atIndex:0];
		}
	}
	return [NSString stringWithString: str];
}

-(int)getIntFromString:(NSString *)theString atLocation:(int)theLocation {
	NSRange theRange = {theLocation, 1};
	return [[theString substringWithRange:theRange] intValue];
}

- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y {
	OSCMessage *newMsg = [OSCMessage createWithAddress:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/press"]]];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:1];
	[self.outPort sendThisMessage:newMsg];
}

- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y
{
	OSCMessage *newMsg = [OSCMessage createWithAddress:[NSString stringWithString:[self.oscPrefix stringByAppendingString:@"/press"]]];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:0];
	[self.outPort sendThisMessage:newMsg];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[outPort release];
	[mainViewController release];
	[oscPrefix release];
    [window release];
    [super dealloc];
}

@end


