//
//  MainView.m
//  haplome
//
//  Created by Todd Treece on 2/18/10.
//  Copyright 2010 Todd Treece. All rights reserved.
//

#import "MainView.h"
#import "AppDelegate_iPad.h"
#import "AppDelegate_iPhone.h"
@implementation MainView
@synthesize buttonArray;
@synthesize rectObject;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setMultipleTouchEnabled:YES];
		setup = FALSE;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	ctx = UIGraphicsGetCurrentContext();
	if(setup == FALSE) {
		[self setupView];
	}
	NSUInteger x,y;
	int yvalue;
	int xvalue;
	NSDictionary *dictionary;
	for(y = 0; y < yNumPads; ++y) {
		for(x = 0; x < xNumPads; ++x) {
			yvalue = yNumPads - y - 1;
			xvalue = xNumPads - x - 1;
			dictionary = [NSDictionary dictionaryWithDictionary:[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:xvalue]]];
			rectObject = [dictionary objectForKey:@"rect"];
			[[dictionary objectForKey:@"fill"] setFill];
			[[dictionary objectForKey:@"stroke"] setStroke];
			CGContextFillRect(ctx, [rectObject CGRectValue]);
			CGContextStrokeRectWithWidth(ctx, [rectObject CGRectValue] ,2);	
		}
	}
}

-(void)setupView {
	NSUInteger x,y;
	int yvalue;
	int xvalue;
	yNumPads = 8;
	xNumPads = 8;
	// setup basics
	NSMutableDictionary *yArray = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *xArray = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *propertyArray = [[NSMutableDictionary alloc] init];
	[[UIColor whiteColor] setFill];
	[[UIColor blackColor] setStroke];
	for(y = 0; y < yNumPads; ++y) {
		for(x = 0; x < xNumPads; ++x) {
			yvalue = yNumPads - y - 1;
			xvalue = xNumPads - x - 1;
			rectObject = [NSValue valueWithCGRect:CGRectMake(self.frame.origin.x + x * self.frame.size.width / (float)xNumPads, self.frame.origin.y + y * self.frame.size.height / (float)yNumPads, self.frame.size.width / (float)xNumPads, self.frame.size.height / (float)yNumPads)];
			[propertyArray setObject:rectObject forKey:@"rect"];
			[propertyArray setObject:[UIColor whiteColor] forKey:@"fill"];
			[propertyArray setObject:[UIColor blackColor]	forKey:@"stroke"];
			NSMutableDictionary *tempdDict = [[NSMutableDictionary alloc] init];
			[tempdDict setDictionary:propertyArray];
			[xArray setObject:tempdDict forKey:[NSNumber numberWithInt:xvalue]];
			[tempdDict release];
			tempdDict = nil;
			[propertyArray removeAllObjects];
		}
		[yArray setObject:[NSDictionary dictionaryWithDictionary:xArray] forKey:[NSNumber numberWithInt:y]];
		[xArray removeAllObjects];
	}
	buttonArray = [[NSDictionary alloc] initWithDictionary:yArray];
	[xArray release];
	[yArray release];
	[propertyArray release];
	propertyArray = nil;
	xArray = nil;
	yArray = nil;
	setup = TRUE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
	NSUInteger x,y;
	NSDictionary *dictionary;
	for(y = 0; y < yNumPads; ++y) {
		for(x = 0; x < xNumPads; ++x) {
			dictionary = [NSDictionary dictionaryWithDictionary:[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]]];
			rectObject = [dictionary objectForKey:@"rect"];
			for (UITouch *touch in touches){
				CGPoint location = [touch locationInView:self];
				if (CGRectContainsPoint([rectObject CGRectValue], location)) {
					[appDelegate activateView:x withCol:y];
					/*[[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]] removeObjectForKey:@"fill"];				
					[[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]] setObject:[UIColor redColor] forKey:@"fill"];
					[self setNeedsDisplay];*/
				}
			}

		}
	}
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//UITouch *touch = [touches anyObject];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
	NSUInteger x,y;
	NSDictionary *dictionary;
	for(y = 0; y < yNumPads; ++y) {
		for(x = 0; x < xNumPads; ++x) {
			dictionary = [NSDictionary dictionaryWithDictionary:[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]]];
			rectObject = [dictionary objectForKey:@"rect"];
			for (UITouch *touch in touches){
				CGPoint location = [touch locationInView:self];
				if (CGRectContainsPoint([rectObject CGRectValue], location)) {
					[appDelegate deactivateView:x withCol:y];
					/*[[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]] removeObjectForKey:@"fill"];				
					 [[[buttonArray objectForKey:[NSNumber numberWithInt:y]] objectForKey:[NSNumber numberWithInt:x]] setObject:[UIColor redColor] forKey:@"fill"];
					 [self setNeedsDisplay];*/
				}
			}
			
		}
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
