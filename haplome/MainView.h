//
//  MainView.h
//  haplome
//
//  Created by Todd Treece on 2/18/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MainView : UIView {
	CGContextRef ctx;
	int yNumPads;
	int xNumPads;
	NSDictionary *buttonArray;
	NSValue *rectObject;
	BOOL setup;
}
@property (nonatomic,retain) NSDictionary *buttonArray;
@property (nonatomic,retain) NSValue *rectObject;
-(void)setupView;
@end
