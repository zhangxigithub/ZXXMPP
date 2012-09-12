//
//  ZXXMPPClient.h
//  ZXXMPP
//
//  Created by 张 玺 on 12-9-12.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPP.h"


#define kUser_available      @"available"
#define kUser_unavailable    @"unavailable"
#define kUser_away           @"away"
#define kUser_busy           @"busy"
#define kUser_invisible      @"invisible"

#define kMessage_from        @"from"
#define kMessage_to          @"to"
#define kMessage_body        @"body"
#define kMessage_type        @"type"
#define kMessage_id          @"id"


#define kMessage_chat        @"chat"
#define kMessage_result      @"result"


@protocol ZXXMPPClientDelegate

@optional

-(void)didReceiveMessage:(XMPPMessage *)message;
-(void)didReceivePresence:(XMPPPresence *)presence;
-(void)didReceiveIQ:(XMPPIQ *)iq;

@end



@interface ZXXMPPClient : NSObject<XMPPStreamDelegate>
{
    XMPPStream *xmppStream;
}
@property(nonatomic,strong) XMPPStream *xmppStream;
@property(nonatomic,unsafe_unretained) id<ZXXMPPClientDelegate> delegate;

@property(nonatomic,strong) NSString *host;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) NSString *userPassword;

@property(nonatomic,strong) NSMutableArray *friendList;



+(ZXXMPPClient *)sharedClient;

-(void)changeUserStatus:(NSString *)status;
-(BOOL)connectWithUser:(NSString *)user andPassword:(NSString *)password;

-(void)disconnect;

-(void)sendMessage:(NSString *)message
            toUser:(NSString *)user
   withMessageType:(NSString *)type;

-(void)sendElement:(NSXMLElement *)element;

+(NSDictionary *)messageWithXMPPMessage:(XMPPMessage *)message;
@end
