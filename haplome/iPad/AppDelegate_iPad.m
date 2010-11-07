//
//  AppDelegate_iPad.m
//  haplome
//
//  Created by Todd Treece on 11/2/10.
//

#import "AppDelegate_iPad.h"
#import "MainViewController.h"
#import "Picker.h"
#define kHaplomeIdentifier		@"haplome"


@interface AppDelegate_iPad ()
- (void) setup;
- (void) presentPicker:(NSString*)name;
- (void) send:(const uint8_t)message;
@end

@implementation AppDelegate_iPad

@synthesize window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.window makeKeyAndVisible];
	mainViewController = [MainViewController alloc];
	[window addSubview:mainViewController.view];
	[self setup];
    return YES;
}

- (void) _showAlert:(NSString*)title
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"Check your networking configuration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
	
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
	
	[_server release];
	
	[_picker release];
    [window release];
    [super dealloc];
}

- (void) setup {
	[_server release];
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
	_inReady = NO;
	
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError* error;
	if(_server == nil || ![_server start:&error]) {
		NSLog(@"Failed creating server: %@", error);
		[self _showAlert:@"Failed creating server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kHaplomeIdentifier] name:nil]) {
		[self _showAlert:@"Failed advertising server"];
		return;
	}
	
	[self presentPicker:nil];
}


- (void) presentPicker:(NSString*)name {
	if (!_picker) {
		_picker = [[Picker alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] type:[TCPServer bonjourTypeFromIdentifier:kHaplomeIdentifier]];
		_picker.delegate = self;
	}
	
	_picker.haplomeName = name;
	
	if (!_picker.superview) {
		[window addSubview:_picker];
	}
}

- (void) destroyPicker {
	[_picker removeFromSuperview];
	[_picker release];
	_picker = nil;
}

// If we display an error or an alert that the remote disconnected, handle dismissal and return to setup
- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self setup];
}

- (void) send:(const uint8_t)message
{
	if (_outStream && [_outStream hasSpaceAvailable])
		if([_outStream write:(const uint8_t *)&message maxLength:sizeof(const uint8_t)] == -1)
			[self _showAlert:@"Failed sending data to peer"];
}

- (void) activateView:(NSUInteger)x withCol:(NSUInteger)y
{
	NSUInteger tagValue;
	tagValue = x * 10 + y +1;
	[self send:tagValue | 0x80];
}

- (void) deactivateView:(NSUInteger)x withCol:(NSUInteger)y
{
	NSUInteger tagValue;
	tagValue = x * 10 + y +1;
	[self send:tagValue & 0x7f];
}


- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (void) browserViewController:(BrowserViewController*)bvc didResolveInstance:(NSNetService*)netService
{
	if (!netService) {
		[self setup];
		return;
	}
	
	if (![netService getInputStream:&_inStream outputStream:&_outStream]) {
		[self _showAlert:@"Failed connecting to haplome connect"];
		return;
	}
	
	[self openStreams];
}

@end

@implementation AppDelegate_iPad (NSStreamDelegate)

- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	UIAlertView* alertView;
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			[self destroyPicker];
			
			[_server release];
			_server = nil;
			
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
				alertView = [[UIAlertView alloc] initWithTitle:@"haplome connected!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
				[alertView show];
				[alertView release];
			}
			break;
		}
			
		case NSStreamEventHasBytesAvailable:
		{
			if (stream == _inStream) {
				uint8_t b;
				unsigned int len = 0;
				int yValue, xValue;
				len = [_inStream read:&b maxLength:sizeof(uint8_t)];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd)
						[self _showAlert:@"Failed reading data from haplome connect"];
				} else {
					//We received a remote tap update, forward it to the appropriate view
					if(b & 0x80) {
						b = b & 0x7f;
						if(b < 10){
							xValue = b - 1;
							yValue = 0;
						} else {
							xValue = b % 10 - 1;
							yValue = b - xValue;
							yValue = yValue / 10;
						}
						[mainViewController lightOn:yValue withCol:xValue];
					} else {
						if(b < 10){
							xValue = b - 1;
							yValue = 0;
						} else {
							xValue = b % 10 - 1;
							yValue = b - xValue;
							yValue = yValue / 10;
						}
						[mainViewController lightOff:yValue withCol:xValue];
					}
				}
			}
			break;
		}			
			
		case NSStreamEventEndEncountered:
		{
			//NSArray*				array = [window subviews];
			//TapView*				view;
			UIAlertView*			alertView;
			
			NSLog(@"%s", _cmd);
			
			//Notify all tap views
			/*for(view in array)
			 [view touchUp:YES];*/
			
			alertView = [[UIAlertView alloc] initWithTitle:@"haplome disconnected!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
			[alertView show];
			[alertView release];
			
			break;
		}
	}
}

@end

@implementation AppDelegate_iPad (TCPServerDelegate)

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string
{
	NSLog(@"%s", _cmd);
	[self presentPicker:string];
}

- (void)didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
	
	[self openStreams];
}

@end
