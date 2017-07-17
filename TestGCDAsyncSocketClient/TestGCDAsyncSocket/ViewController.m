//
//  ViewController.m
//  TestGCDAsyncSocket
//
//  Created by sunhongyue on 2017/7/11.
//  Copyright © 2017年 sunhongyue. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *txtIp;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *sendMsg;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
    
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    NSLog(@"First request sent");
    else if (tag == 2)
    NSLog(@"Second request sent");
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",msg);
    
    // 还要写一次这句
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"disconnect");
}

#pragma mark - **************** Btn Aciton

- (IBAction)sendAction:(UIButton *)sender {
    [self sendMessage];
}

- (IBAction)disconnectAction:(id)sender {
    [self.socket disconnect];
}

-(void)sendMessage {
    
    NSData *msg = [self.sendMsg.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *sendMsg = [[NSString alloc] initWithData:msg encoding:NSUTF8StringEncoding];
    NSLog(@"Data Send: %@",sendMsg);
    
    [self.socket writeData:msg withTimeout:-1 tag:1];
    
}

-(IBAction)connectToServer {
    NSError *err = nil;
    if (![self.socket connectToHost:self.txtIp.text onPort:[self.port.text integerValue]  error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    } else {
        NSLog(@"connect");
    }
}

@end
