//
//  AppDelegate_iPhone.h
//  haplome
//
//  Created by Todd Treece on 11/2/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;
@class Reachability;
@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MainViewController *mainViewController;
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y;
- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) _showAlert:(NSString*)title;
@end

