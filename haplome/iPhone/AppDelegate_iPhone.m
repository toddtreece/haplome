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
	manager = [[OSCManager alloc] init];
	[manager setDelegate:self];
	[manager createNewInputForPort:1234 withLabel:@"haplome"];
}

- (void)setupDefaults {
	oscPrefix = @"/osc";
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

- (void) receivedOSCMessage:(OSCMessage *)m     {
	//NSLog(@"%s ... %@",__func__,m);
	NSString *addy = [m address];
	if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led"]]]) {
		[self receivedLed:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led_col"]]]) {
		[self receivedCol:m];
	} else if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led_row"]]]) {
		[self receivedRow:m];
	} else if ([addy isEqualToString:@"/sys/connection"]) {
		[self receivedConnectionInfo:m];
	} else if ([addy isEqualToString:@"/sys/prefix"]) {
		oscPrefix = [[m value] stringValue];
	}
}

- (void) receivedConnectionInfo:(OSCMessage *)message {
	NSString *ipAddress = [[[message valueArray] objectAtIndex:0] stringValue];
	int portInfo = [[[message valueArray] objectAtIndex:1] intValue];
	outPort = [manager createNewOutputToAddress:ipAddress atPort:portInfo withLabel:@"haplome"];
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
				
				
- (void) receivedRow:(OSCMessage *)message {
	int toggleValue, i;
	int rowVal = [[[message valueArray] objectAtIndex:0] intValue];
	int colVal = [[[message valueArray] objectAtIndex:1] intValue];
	for(i=0; i < xNumPads; ++i) {
		toggleValue = colVal % 2;
		colVal = colVal / 2;
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
	for(i=0; i < yNumPads; ++i) {
		toggleValue = rowVal % 2;
		rowVal = rowVal / 2;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y
{
	OSCMessage *newMsg = [OSCMessage createWithAddress:@"/osc/press"];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:1];
	[outPort sendThisMessage:newMsg];
	//[mainViewController lightOn:x withCol:y];
}

- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y
{
	OSCMessage *newMsg = [OSCMessage createWithAddress:@"/osc/press"];
	[newMsg addInt:y];
	[newMsg addInt:x];
	[newMsg addInt:0];
	[outPort sendThisMessage:newMsg];
	//[mainViewController lightOff:x withCol:y];
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


