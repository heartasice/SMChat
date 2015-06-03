//
//  SMChatViewController.h
//  SMChat
//
//  Created by Eric Che on 6/3/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface SMChatViewController : JSQMessagesViewController
@property(nonatomic,strong)NSMutableArray<JSQMessageData> *chatMessages;

@end
