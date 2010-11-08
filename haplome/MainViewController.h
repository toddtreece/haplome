//
//  MainViewController.h
//  haplome
//
//  Created by Todd Treece on 2/18/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController  {
	NSString * backColor;
	NSString * highlightColor;
}
@property (nonatomic,retain) NSString * backColor;
@property (nonatomic,retain) NSString * highlightColor;
- (void)lightOn:(int)rowVal withCol:(int)colVal;
- (void)lightOff:(int)rowVal withCol:(int)colVal;
@end
