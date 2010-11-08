//
//  AppDelegate_iPhone.h
//  haplome
//
//  Created by Todd Treece on 11/2/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"
#import "Picker.h"
#import "TCPServer.h"
@class MainViewController;
@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate, UIActionSheetDelegate, BrowserViewControllerDelegate, TCPServerDelegate,NSStreamDelegate> {
    UIWindow *window;
	Picker*				_picker;
	TCPServer*			_server;
	NSInputStream*		_inStream;
	NSOutputStream*		_outStream;
	BOOL				_inReady;
	BOOL				_outReady;
	MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y;
- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y;
@end

