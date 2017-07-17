//
//  ViewController.m
//  TestSocketServer
//
//  Created by sunhongyue on 2017/7/13.
//  Copyright © 2017年 sunhongyue. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate>
@property (weak) IBOutlet NSTextField *msgText;

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (weak) IBOutlet NSTextField *msgSendText;

@property (weak) IBOutlet NSScrollView *outputTextView;

@property (weak) IBOutlet NSTextField *portText;
@property (unsafe_unretained) IBOutlet NSTextView *resultTextView;
@property (weak) IBOutlet NSButton *disconnectBtn;
@property (weak) IBOutlet NSButton *listenBtn;
@property (weak) IBOutlet NSButton *sendBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.listenBtn setTarget:self];
    [self.listenBtn setAction:@selector(listenBtnStateChangeAction:)];
    
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [self logMessage:[NSString stringWithFormat:@"收到来自[%@:%d]的连接", [newSocket connectedHost], [newSocket connectedPort]]];
    self.asyncSocket = newSocket;
    NSString *welcomMessage = @"Hello from the server\r\n";
    [self.asyncSocket writeData:[welcomMessage dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [sock readDataWithTimeout:-1 tag:0];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self logMessage:[NSString stringWithFormat:@"接收到数据:%@", msg]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if (err) {
        if(err.localizedDescription) {
            [self logMessage:err.localizedDescription];
            [self.listenBtn setState:NSOffState];
            [self listenBtnStateChangeAction:self.listenBtn];
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - **************** Action
- (IBAction)sendAction:(NSButton *)sender {
    NSData *msg = [[NSString stringWithFormat:@"%@\r\n", self.msgSendText.stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *sendMsg = [[NSString alloc] initWithData:msg encoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:msg withTimeout:-1 tag:1];
}

- (void)listenBtnStateChangeAction:(NSButton *)sender {
    if (sender.state == NSOnState) {
        // 开始监听操作
        [sender setTitle:@"断开连接"];
        
        NSError *err = nil;
        NSString *port = self.portText.stringValue;
        if (!port || port.length == 0) return;
        NSInteger portNum = [port integerValue];
        if (portNum < 0 || portNum > 65535) return;
        if ([_asyncSocket isConnected]) [_asyncSocket disconnect];
        if (_asyncSocket) {
            _asyncSocket = nil;
            _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        }
        if (![_asyncSocket acceptOnPort:portNum error:&err]){
            if (err) [self logMessage:@"已经在监听"];
            //[self logMessage:[NSString stringWithFormat:@"\r\nError in acceptOnPort:error: -> %@", err]];
        } else {
            NSString *showText = [self.resultTextView.string stringByAppendingString:[NSString stringWithFormat:@"\r\n 开始监听..."]];
            [self logMessage:showText];
        }
    } else if (sender.state == NSOffState) {
        // 断开连接操作
        [sender setTitle:@"开始监听"];
        
        if ([self.asyncSocket isConnected]) {
            if ([self.asyncSocket isDisconnected])
                [self logMessage:@"已断开连接"];
            [self.asyncSocket disconnect];
        } else {
            [self logMessage:@"未连接"];
        }
    }
}

#pragma mark - **************** Private

- (void)logMessage:(NSString *)message
{
    if (message) {
        [self appendMessage:message];
    }
}

- (void)appendMessage:(NSString *)message
{
    NSString *messageWithNewLine = [message stringByAppendingString:@"\n"];
    
    // Smart Scrolling
    BOOL scroll = (NSMaxY(self.outputTextView.visibleRect) == NSMaxY(self.outputTextView.bounds));
    
    
    // Append string to textview
    [self.resultTextView.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:messageWithNewLine]];
    
    if (scroll) // Scroll to end of the textview contents
        [self.resultTextView scrollRangeToVisible: NSMakeRange(self.resultTextView.string.length, 0)];
}

@end
