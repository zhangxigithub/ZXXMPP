//
//  ViewController.h
//  ZXXMPP
//
//  Created by 张玺 on 12-9-11.
//  Copyright (c) 2012年 张玺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXXMPPClient.h"
#import "UIBubbleTableViewDataSource.h"


@class UIBubbleTableView;

@interface ViewController : UIViewController<UIBubbleTableViewDataSource,ZXXMPPClientDelegate>
{
    NSMutableArray *bubbleData;
}

@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;

- (IBAction)action:(id)sender;



@end
