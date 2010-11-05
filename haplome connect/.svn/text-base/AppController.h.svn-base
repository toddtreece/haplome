#import <Foundation/Foundation.h>
#import "TCPServer.h"

@class BBOSCListener;
@class BBOSCSender;
@class BBOSCMessage;

@interface AppController : NSObject <TCPServerDelegate> {
	BBOSCListener * oscListener;
	BBOSCSender * oscSender;
	TCPServer*			_server;
	NSInputStream*		_inStream;
	NSOutputStream*		_outStream;
	BOOL				_inReady;
	BOOL				_outReady;
	IBOutlet NSLevelIndicator * bonjourListenStatus;
	IBOutlet NSLevelIndicator * bonjourConnectStatus;
	IBOutlet NSTextField * oscPrefixField;
	NSString*		oscPrefixFromField;
	NSString*		oscPrefix;
	BBOSCMessage * newMessage;
}
@property (retain) BBOSCListener* oscListener;
@property (retain) BBOSCSender* oscSender;
@property (retain) NSString* oscPrefix;
@property (retain) NSString* oscPrefixFromField;
@property (retain) BBOSCMessage * newMessage;
@property (retain) TCPServer*			_server;
@property (retain) NSInputStream*		_inStream;
@property (retain) NSOutputStream*		_outStream;
@property (retain) IBOutlet NSLevelIndicator * bonjourListenStatus;
@property (retain) IBOutlet NSLevelIndicator * bonjourConnectStatus;
@property (retain) IBOutlet NSTextField * oscPrefixField;
- (void) _showAlert:(NSString*)title;
- (void) dispatchRawPacket:(NSData*)someData;
- (void) dispatchMessage:(BBOSCMessage*)message;
- (void) send:(const uint8_t)message;
- (void) doTest;

@end
