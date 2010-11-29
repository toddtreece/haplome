//
//  AppDelegate_iPhone.h
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

#import <UIKit/UIKit.h>
#import <VVOSC/VVOSC.h>
@class MainViewController;
@class Reachability;
@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	NSString *oscPrefix;
	MainViewController *mainViewController;
	OSCManager *manager;
	OSCOutPort *outPort;
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) OSCManager *manager;
@property (nonatomic, retain) NSString *oscPrefix;
@property (nonatomic, retain) OSCOutPort *outPort;
- (void) receivedLed:(OSCMessage *)message;
- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y;
- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) _showAlert:(NSString*)title;
@end

