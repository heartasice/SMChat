//
//  SMRecentChatMessageModel.h
//  SMChat
//
//  Created by Eric Che on 2/6/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import "JSONModel.h"
#import "SMChatMessageModel.h"
@interface SMRecentChatMessageModel : SMChatMessageModel
@property(nonatomic,strong)NSString *fromUserName;
@property(nonatomic,strong)NSString *fromUserAvatarUrlString;
@property(nonatomic,strong)NSString *toUserName;
@property(nonatomic,strong)NSString *toUserAvatarUrlString;
@property(nonatomic,assign)NSInteger priority;

@end
