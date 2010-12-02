//
//  MainViewController.m
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
	} else {
		backColor = @"whiteColor";
	}
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"color_pref"] != nil) {
		highlightColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"color_pref"];
	} else {
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
	//[mainView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:0 waitUntilDone:NO];
}

- (void)lightOff:(int)rowVal withCol:(int)colVal {
	MainView *mainView = (MainView *)self.view;
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] removeObjectForKey:@"fill"];				
	[[[mainView.buttonArray objectForKey:[NSNumber numberWithInt:colVal]] objectForKey:[NSNumber numberWithInt:rowVal]] setObject:[UIColor performSelector:NSSelectorFromString(backColor)] forKey:@"fill"];
	[mainView setNeedsDisplay];
	//[mainView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:0 waitUntilDone:NO];
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