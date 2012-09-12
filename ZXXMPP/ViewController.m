//
//  ViewController.m
//  ZXXMPP
//
//  Created by 张玺 on 12-9-11.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import "ViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@implementation ViewController
@synthesize bubbleTable;


- (IBAction)action:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0:
            [[ZXXMPPClient sharedClient] changeUserStatus:kUser_available];
            [[ZXXMPPClient sharedClient] sendMessage:@"helloooo"
                                              toUser:@"zhangxi@zhangxi.local"
                                     withMessageType:kMessage_chat];
            
            [self addMessage:@"helloooo" withDate:[NSDate date] forMe:YES];

            break;
        case 1:
            [[ZXXMPPClient sharedClient] changeUserStatus:kUser_unavailable];
            break;
        case 2:
            [[ZXXMPPClient sharedClient] changeUserStatus:kUser_available];
            break;
        case 3:
        {
            //好友列表
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
            [iq addChild:[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"]];
            
            [[ZXXMPPClient sharedClient] sendElement:iq];

        }
            break;
        case 4:
            //添加好友
            /*
             <iq type='set'>
             <query xmlns='jabber:iq:roster'>
             <item jid='romeo@montague.net' name='Romeo Montague'/>
             </query>
             </iq>
             
             */
        {
            XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];

            
            NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
            
            NSXMLElement *jid = [NSXMLElement elementWithName:@"item"];
            
            [jid addAttributeWithName:@"jid" stringValue:@"user1@zhangxi.local"];
            [query addChild:jid];
            
            [iq addChild:query];
            
            NSLog(@"%@\n\n\n\n\n",iq);
            [[ZXXMPPClient sharedClient] sendElement:iq];
        }
            break;
        case 5:

            break;
        case 6:

            break;
            
        default:
            break;
    }
}

-(void)addMessage:(NSString *)message withDate:(NSDate *)date forMe:(BOOL)isMe
{
    if(message == nil)return;
    NSBubbleType type = isMe?BubbleTypeMine:BubbleTypeSomeoneElse;
    
    
    [bubbleData addObject:[NSBubbleData dataWithText:message
                                             andDate:date
                                             andType:type]];
    [bubbleTable reloadData];
    [bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:bubbleData.count-1 inSection:0]
                       atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"%@",message);
    NSLog(@"%@",[ZXXMPPClient messageWithXMPPMessage:message]);
    //return;
    NSString *body = [[message elementForName:@"body"] stringValue];
    [self addMessage:body withDate:[NSDate date] forMe:NO];
}
-(void)didReceivePresence:(XMPPPresence *)presence
{

    NSLog(@"presence = %@", presence);
    
    
    
    
    NSLog(@"%@:%@",[[presence from] user],[[presence type]isEqualToString:kUser_available]?@"上线":@"下线");
    
    
    
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[[ZXXMPPClient sharedClient].xmppStream myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            
            //用户列表委托(后面讲)
            //            [chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
            
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            //用户列表委托(后面讲)
            //            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
        }
        
    }
}
-(void)didReceiveIQ:(XMPPIQ *)iq
{
    
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bubbleData = [NSMutableArray array];
    bubbleTable.bubbleDataSource = self;
    [ZXXMPPClient sharedClient].host = @"10.30.2.213";
    [ZXXMPPClient sharedClient].delegate = self;
    [[ZXXMPPClient sharedClient]connectWithUser:@"test@zhangxi.local" andPassword:@"test"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setBubbleTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
