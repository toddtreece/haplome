/*

File: Picker.m
Abstract: 
 A view that displays both the currently advertised haplome name and a list of
other haplomes
 available on the local network (discovered & displayed by
BrowserViewController).
 

Version: 1.5

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "Picker.h"

#define kOffset 5.0

@interface Picker ()
@property (nonatomic, retain, readwrite) BrowserViewController* bvc;
@property (nonatomic, retain, readwrite) UILabel* haplomeNameLabel;
@end

@implementation Picker

@synthesize bvc = _bvc;
@synthesize haplomeNameLabel = _haplomeNameLabel;

- (id)initWithFrame:(CGRect)frame type:(NSString*)type {
	if ((self = [super initWithFrame:frame])) {
		self.bvc = [[BrowserViewController alloc] initWithTitle:nil showDisclosureIndicators:NO showCancelButton:NO];
		[self.bvc searchForServicesOfType:type inDomain:@"local"];
		
		self.opaque = YES;
		self.backgroundColor = [UIColor blackColor];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_768.png"]];
			[self addSubview:img];
			[img release];
			[self.bvc.view setFrame:CGRectMake(0, 174, self.bounds.size.width, self.bounds.size.height-348)];
		} else {
			UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_320.png"]];
			[self addSubview:img];
			[img release];
			[self.bvc.view setFrame:CGRectMake(0, 87, self.bounds.size.width, self.bounds.size.height-174)];
		}
		
		[self addSubview:self.bvc.view];
		
	}

	return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)dealloc {
	// Cleanup any running resolve and free memory
	[self.bvc release];
	[self.haplomeNameLabel release];
	
	[super dealloc];
}


- (id<BrowserViewControllerDelegate>)delegate {
	return self.bvc.delegate;
}


- (void)setDelegate:(id<BrowserViewControllerDelegate>)delegate {
	[self.bvc setDelegate:delegate];
}

- (NSString *)haplomeName {
	return self.haplomeNameLabel.text;
}

- (void)setHaplomeName:(NSString *)string {
	[self.haplomeNameLabel setText:string];
	[self.bvc setOwnName:string];
}

@end
