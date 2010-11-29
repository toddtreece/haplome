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
    
    // Override point for customization after application launch.
    oscPrefix = @"/osc";
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	mainViewController = [MainViewController alloc];
	[window addSubview:mainViewController.view];
	[self.window makeKeyAndVisible];
	manager = [[OSCManager alloc] init];
	[manager setDelegate:self];
	[manager createNewInputForPort:1234];
	outPort = [manager createNewOutputToAddress:@"10.0.100.5" atPort:8000];
	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
    return YES;
}

- (void) receivedOSCMessage:(OSCMessage *)m     {
	//NSLog(@"%s ... %@",__func__,m);
	NSString *addy = [m address];
	if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led"]]]) {
		[self receivedLed:m];
	}
}

- (void) receivedLed:(OSCMessage *)message {
	int colVal = [[[message valueArray] objectAtIndex:0] intValue];
	int rowVal = [[[message valueArray] objectAtIndex:1] intValue];
	int command = [[[message valueArray] objectAtIndex:2] intValue];
	if(command == 1) {
		if(colVal <= 7 && rowVal <=7){
			[mainViewController lightOn:rowVal withCol:colVal];
			[window setNeedsDisplay];
		}
	}
	
	if(command == 0) {
		if(colVal <= 7 && rowVal <=7){
			[mainViewController lightOff:rowVal withCol:colVal];
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


