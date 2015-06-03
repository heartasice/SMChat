//
//  SMChatMessageModel.h
//  SMChat
//
//  Created by Eric Che on 2/6/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import "JSONModel.h"
#import "JSQMessageData.h"
@interface SMChatMessageModel : JSONModel
//自动增长 id
@property(nonatomic,assign)NSInteger messageId;
//当前用户id
@property(nonatomic,strong)NSString *fromUserId;
//聊天对象id
@property(nonatomic,strong)NSString *toUserId;
//发送还是接收
@property(nonatomic,assign)NSNumber *isOutGoing;
//消息类型 1 文本 2 图片 3 语音 4 视频
@property(nonatomic,assign)NSInteger messageType;
//消息正文
@property(nonatomic,strong)NSString *messageBody;
//发送状态
@property(nonatomic,assign)NSInteger sendStatus;
//发送时间
@property(nonatomic,strong)NSDate *timestamp;
@end
