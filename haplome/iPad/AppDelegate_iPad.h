//
//  AppDelegate_iPad.h
//  haplome
//
//  Created by Todd Treece on 11/2/10.
//  Copyright 2010 Mid Michigan Community College. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;
@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end

