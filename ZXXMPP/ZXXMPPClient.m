//
//  ZXXMPPClient.m
//  ZXXMPP
//
//  Created by 张 玺 on 12-9-12.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import "ZXXMPPClient.h"

@implementation ZXXMPPClient



static ZXXMPPClient *client;
+(ZXXMPPClient *)sharedClient
{
    if(client == nil) client = [[ZXXMPPClient alloc] init];
    return client;
}


- (id)init
{
    self = [super init];
    if (self) {
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    }
    return self;
}

-(void)changeUserStatus:(NSString *)status
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:status];
    [xmppStream sendElement:presence];
}


-(BOOL)connectWithUser:(NSString *)user andPassword:(NSString *)password
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (user == nil || password == nil || self.host == nil) {
        return NO;
    }
    
    
    //设置服务器
    [xmppStream setHostName:self.host];
    [xmppStream setMyJID:[XMPPJID jidWithString:user]];
    
    self.userId = user;
    self.userPassword = password;
    
    
    //连接服务器
    NSError *error = nil;
    if (![xmppStream connect:&error]) {
        NSLog(@"error %@", error);
        return NO;
    }
    
    return YES;
}
-(void)sendMessage:(NSString *)message toUser:(NSString *)user withMessageType:(NSString *)type
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:type];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:user];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:self.userId];
    //组合
    [mes addChild:body];
    
    //发送消息
    [xmppStream sendElement:mes];
}
-(void)sendElement:(NSXMLElement *)element
{
    [xmppStream sendElement:element];
}


-(void)disconnect{
    
    [self changeUserStatus:kUser_unavailable];
    [xmppStream disconnect];
    
}

+(NSDictionary *)messageWithXMPPMessage:(XMPPMessage *)message
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    
    NSString *body = [[message elementForName:@"body"] stringValue];
    if(body == nil) body = @"";
    
    NSString *from      = [message attributeStringValueForName:kMessage_from withDefaultValue:@""];
    NSString *to        = [message attributeStringValueForName:kMessage_to   withDefaultValue:@""];
    NSString *type      = [message attributeStringValueForName:kMessage_type withDefaultValue:@""];
    NSString *messageId = [message attributeStringValueForName:kMessage_id   withDefaultValue:@""];
    
    
    
    ;
    
    [info setObject:body      forKey:kMessage_body];
    [info setObject:from      forKey:kMessage_from];
    [info setObject:to        forKey:kMessage_to];
    [info setObject:type      forKey:kMessage_type];
    [info setObject:messageId forKey:kMessage_id];
    
    return info;
}



//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    NSError *error = nil;
    //验证密码
    [xmppStream authenticateWithPassword:self.userPassword error:&error];
    if(error != nil)
    {
        NSLog(@"error:%@",error);
    }
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    [self changeUserStatus:kUser_available];
    NSLog(@"log in!");
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    id obj = self.delegate;
    if([obj respondsToSelector:@selector(didReceiveMessage:)])
        [self.delegate didReceiveMessage:message];
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    id obj = self.delegate;
    if([obj respondsToSelector:@selector(didReceivePresence:)])
        [self.delegate didReceivePresence:presence];
    return;
}

//收到IQ
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    id obj = self.delegate;
    if([obj respondsToSelector:@selector(didReveiveIQ:)])
        [self.delegate didReceiveIQ:iq];
    
    return YES;
}


@end
