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


- (void)loadView {
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		self.view = [[MainView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];		
	} else {
		self.view = [[MainView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];		
	}

	//self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)lightOn:(int)rowVal withCol:(int)colVal {
	MainView *mainView = (MainView *)self.view;
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] removeObjectForKey:@"fill"];				
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] setObject:[UIColor redColor] forKey:@"fill"];
	[mainView setNeedsDisplay];
}

- (void)lightOff:(int)rowVal withCol:(int)colVal {
	MainView *mainView = (MainView *)self.view;
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] removeObjectForKey:@"fill"];				
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] setObject:[UIColor whiteColor] forKey:@"fill"];
	[mainView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}




@end