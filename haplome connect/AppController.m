#import "AppController.h"
#import "BBOSCArgument.h"
#import "BBOSCListener.h"
#import "BBOSCDispatcher.h"
#import "BBOSCDataUtilities.h"
#import "BBOSCMessage.h"
#import "BBOSCBundle.h"
#import "BBOSCDecoder.h"
#import "BBOSCSender.h"
#import "BBOSCAddress.h"

#define kHaplomeIdentifier		@"haplome"

@interface AppController ()
- (void) setup;
@end

@implementation AppController

@synthesize oscListener;
@synthesize oscSender;
@synthesize bonjourListenStatus;
@synthesize bonjourConnectStatus;
@synthesize oscPrefixField;
@synthesize oscPrefix;
@synthesize oscPrefixFromField;
@synthesize newMessage;
@synthesize _server;
@synthesize _inStream;
@synthesize _outStream;


-(void)awakeFromNib
{
	oscPrefixFromField = [oscPrefixField stringValue];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOscPrefix:)  name:NSControlTextDidChangeNotification object:oscPrefixField];
	[self doTest];
	[self setup];
}
- (void) _showAlert:(NSString*)title
{
	NSAlert * alertView = [NSAlert alertWithMessageText:@"Haplome Connect Alert" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:title];
	[alertView runModal];
}
-(void)doTest
{
	BBOSCListener * newListener = [[BBOSCListener alloc] init];
	[newListener setDelegate:self];
	[newListener startListeningOnPort:8080];
	self.oscListener = newListener;

}
-(void)changeOscPrefix:(NSNotification *)aNotification
{
	if([aNotification object] == oscPrefixField)
	{
		oscPrefixFromField = [oscPrefixField stringValue];
	}
}

-(void)dispatchRawPacket:(NSData*)someData
{
	id decodedPacket = [BBOSCDecoder decodeData:someData];
	
	[self dispatchMessage:decodedPacket];
	
	
}


-(void)dispatchMessage:(BBOSCMessage*)message
{
	
	NSString * addy = [[[message address] address] lowercaseString];
	oscPrefix = oscPrefixFromField;
	if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led"]]]) {
		
		int colVal = [[[message attachedObjects] objectAtIndex:0] intValue];
		int rowVal = [[[message attachedObjects] objectAtIndex:1] intValue];
		int command = [[[message attachedObjects] objectAtIndex:2] intValue];
		NSUInteger tagValue = rowVal * 10 + colVal +1;
		if(command == 1) {
			if(colVal <= 7 && rowVal <=7){
				
				[self send:tagValue | 0x80];
				
			}
		}
		
		if(command == 0) {
			if(colVal <= 7 && rowVal <=7){
				
				[self send:tagValue & 0x7f];
				
			}
			
		}
		
	} else if ([addy isEqualToString:@"/sys/prefix"]) {
	
		[oscPrefixField setStringValue:[[[message attachedObjects] objectAtIndex:0] stringValue]];
		
	} else if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led_col"]]]) {
		int toggleValue, i;
		NSUInteger tagValue;
		int colVal = [[[message attachedObjects] objectAtIndex:0] intValue];
		int rowVal = [[[message attachedObjects] objectAtIndex:1] intValue];
		for(i=0; i < 8; ++i) {
		
			toggleValue = rowVal % 2;
			rowVal = rowVal / 2;
			if(toggleValue == 1) {
				tagValue = i * 10 + colVal +1;
				if(colVal <= 7 && i <=7){
					
					[self send:tagValue | 0x80];
					
				}				
			} else if (toggleValue ==0) {
			
				tagValue = i * 10 + colVal +1;
				if(colVal <= 7 && i <=7){
					
					[self send:tagValue & 0x7f];
					
				}
			}
			
			
		}
		
	} else if ([addy isEqualToString:[NSString stringWithString:[oscPrefix stringByAppendingString:@"/led_row"]]]) {
		int toggleValue, i;
		NSUInteger tagValue;
		int colVal = [[[message attachedObjects] objectAtIndex:0] intValue];
		int rowVal = [[[message attachedObjects] objectAtIndex:1] intValue];
		for(i=0; i < 8; ++i) {
			
			toggleValue = rowVal % 2;
			rowVal = rowVal / 2;
			if(toggleValue == 1) {
				tagValue = colVal * 10 + i +1;
				if(colVal <= 7 && i <=7){
					
					[self send:tagValue | 0x80];
					
				}				
			} else if (toggleValue ==0) {
				
				tagValue = colVal * 10 + i +1;
				if(colVal <= 7 && i <=7){
					
					[self send:tagValue & 0x7f];
					
				}
			}
			
			
		}
		
	}
	
	
	
}


- (void) dealloc
{	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
	
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
	
	[_server release];
	
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
	[bonjourConnectStatus setFloatValue:0];
	[bonjourListenStatus setFloatValue:1];
	NSError* error;
	if(_server == nil || ![_server start:&error]) {
		NSLog(@"Failed creating server: %@", error);
		[bonjourConnectStatus setFloatValue:0];
		[bonjourListenStatus setFloatValue:0];
		[self _showAlert:@"Failed creating haplome connect server"];
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kHaplomeIdentifier] name:nil]) {
		[bonjourConnectStatus setFloatValue:0];
		[bonjourListenStatus setFloatValue:0];
		[self _showAlert:@"Failed advertising haplome connect server"];

		return;
	}
	
}
- (void) send:(const uint8_t)message
{
	if (_outStream && [_outStream hasSpaceAvailable])
		if([_outStream write:(const uint8_t *)&message maxLength:sizeof(const uint8_t)] == -1) {
			[bonjourConnectStatus setFloatValue:0];
			[bonjourListenStatus setFloatValue:0];
			[self _showAlert:@"Failed sending data to haplome"];
			[self setup];

		}
	
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

@end

@implementation AppController (NSStreamDelegate)


- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			
			[_server release];
			_server = nil;
			
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
				[bonjourConnectStatus setFloatValue:1];
				[bonjourListenStatus setFloatValue:0];
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
					if ([stream streamStatus] != NSStreamStatusAtEnd) {
						[self _showAlert:@"Failed reading data from haplome"];
						[self setup];
					}

				} else {
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
						oscPrefix = oscPrefixFromField;
						oscPrefix = [oscPrefix stringByAppendingString:@"/press"];
						newMessage = [BBOSCMessage messageWithBBOSCAddress:[BBOSCAddress addressWithString:oscPrefix]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:xValue]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:yValue]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:1]];

						[self setOscSender:[BBOSCSender senderWithDestinationHostName:@"localhost" portNumber:8000]];
						
						[[self oscSender] sendOSCPacket:newMessage];
					
						
					
					} else {
												
						if(b < 10){
							xValue = b - 1;
							yValue = 0;
						} else {
							xValue = b % 10 - 1;
							yValue = b - xValue;
							yValue = yValue / 10;
						}
						oscPrefix = oscPrefixFromField;
						oscPrefix = [oscPrefix stringByAppendingString:@"/press"];
						newMessage = [BBOSCMessage messageWithBBOSCAddress:[BBOSCAddress addressWithString:oscPrefix]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:xValue]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:yValue]];
						[newMessage attachArgument:[BBOSCArgument argumentWithInt:0]];

						[self setOscSender:[BBOSCSender senderWithDestinationHostName:@"localhost" portNumber:8000]];
						
						[[self oscSender] sendOSCPacket:newMessage];
						
						
					}

				}
			}
			break;
		}	
			
		case NSStreamEventEndEncountered:
		{
			NSAlert* alertView;
			NSLog(@"%s", _cmd);
			alertView = [NSAlert alertWithMessageText:@"haplome disconnected!" defaultButton:@"Continue" alternateButton:nil otherButton:nil informativeTextWithFormat:@"press continue to reconnect" ];
			[alertView runModal];
			[self setup];

			break;
		}
	
		 
	}
}

@end

@implementation AppController (TCPServerDelegate)

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string
{
	NSLog(@"%s", _cmd);
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