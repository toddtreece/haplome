//
//  MainViewController.m
//  haplome
//
//  Created by Todd Treece on 2/18/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController
@synthesize backColor;
@synthesize highlightColor;

- (void)loadView {
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		self.view = [[MainView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];		
	} else {
		self.view = [[MainView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];		
	}
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"back_pref"] != nil) {
		backColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"back_pref"];
		highlightColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"color_pref"];
	} else {
		backColor = @"whiteColor";
		highlightColor = @"orangeColor";
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)lightOn:(int)rowVal withCol:(int)colVal {
	MainView *mainView = (MainView *)self.view;
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] removeObjectForKey:@"fill"];				
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] setObject:[UIColor performSelector:NSSelectorFromString(highlightColor)] forKey:@"fill"];
	[mainView setNeedsDisplay];
}

- (void)lightOff:(int)rowVal withCol:(int)colVal {
	MainView *mainView = (MainView *)self.view;
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] removeObjectForKey:@"fill"];				
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] setObject:[UIColor performSelector:NSSelectorFromString(backColor)] forKey:@"fill"];
	[mainView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

}

- (void)dealloc {
	[highlightColor release];
	[backColor release];
    [super dealloc];
}

@end