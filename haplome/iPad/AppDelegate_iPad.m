//
//  AppDelegate_iPad.m
//  haplome
//
//  Created by Todd Treece on 11/2/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "Reachability.h"
#import "MainViewController.h"
#define kHaplomeIdentifier		@"haplome"

@implementation AppDelegate_iPad

@synthesize window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
    [self.window makeKeyAndVisible];
	mainViewController = [MainViewController alloc];
	[window addSubview:mainViewController.view];
    return YES;
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


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y
{
	NSUInteger tagValue;
	tagValue = x * 10 + y +1;
	//[self send:tagValue | 0x80];
}

- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y
{
	NSUInteger tagValue;
	tagValue = x * 10 + y +1;
	//[self send:tagValue & 0x7f];
}

@end
