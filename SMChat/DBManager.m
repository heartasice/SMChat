//
//  DBManager.m
//  SMChat
//
//  Created by Eric Che on 2/6/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import "DBManager.h"
#import "FMDB.h"
#import "SMChatMessageModel.h"
#define DATA_BASE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]stringByAppendingString:@"/SMChat.db"]
@implementation DBManager
+(FMDatabaseQueue *)sharedDatabaseQueue
{
    static FMDatabaseQueue *_share=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share=[[FMDatabaseQueue alloc]initWithPath:DATA_BASE_PATH];
    });
    
    [_share inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"sm_message"]) {
            [db executeUpdate:@"create table sm_message (messageId integer primary key not null,fromUserId text,toUserId text,isOutGoing integer,messageType integer,messageBody text ,sendStatus integer,timestamp datetime)"];
        }
        if (![db tableExists:@"sm_recent_message"]) {
            [db executeUpdate:@"create table sm_recent_message (messageId integer primary key not null,fromUserId text,toUserId text,isOutGoing integer,messageType integer,messageBody text ,sendStatus integer,timestamp datetime,fromUserName text,fromUserAvatarUrlString text,toUserName text,toUserAvatarUrlString text,priority integer)"];
        }
        
    }];
    return _share;
}

+(FMDatabase *)sharedDatabase
{
    static FMDatabase *_share=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share=[[FMDatabase alloc]initWithPath:DATA_BASE_PATH];
    });
    
    
    return _share;
}

+(NSInteger)addChatMessage:(SMChatMessageModel*)chatMessageModel{
    FMDatabase *db = [DBManager sharedDatabase];
    if (![db open]) {
        NSLog(@"db open failed");
    }
    [db executeUpdate:@"replace into sm_message (fromUserId,toUserId,isOutGoing,messageType,messageBody,sendStatus,timestamp) values (?,?,?,?,?,?,?)",chatMessageModel.fromUserId,chatMessageModel.toUserId,chatMessageModel.isOutGoing,chatMessageModel.messageType,chatMessageModel.messageBody,chatMessageModel.sendStatus,chatMessageModel.timestamp];
    NSInteger messageId=[db lastInsertRowId];
    [db close];
    
    return messageId;
}
+(NSArray*)getChatMessageByCurrentUserId:(NSString*)currentUserId setToUserId:(NSString*)toUserId setPageIndex:(NSNumber*)pageIndex setPageSize:(NSNumber*)pageSize{
    FMDatabase *db=[DBManager sharedDatabase];
    if (![db open]) {
        return nil;
    }
    FMResultSet *rs=[db executeQuery:@"select * from sm_message where fromUserId=? and toUserId=? order by messageId desc limit ? offset ?",currentUserId,toUserId,pageSize,pageIndex];
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    while ([rs next]) {
        SMChatMessageModel *messageModel=[[SMChatMessageModel alloc]init];
        messageModel.messageId=[rs intForColumn:@"messageId"];
        messageModel.messageBody=[rs stringForColumn:@"messageBody"];
        messageModel.timestamp=[rs dateForColumn:@"timestamp"];
        messageModel.fromUserId=[rs stringForColumn:@"fromUserId"];
        messageModel.toUserId=[rs stringForColumn:@"toUserId"];
        messageModel.isOutGoing=@([rs intForColumn:@"isOutGoing"]);
        [arr addObject:messageModel];
    }
    [db close];
    return arr;
}
@end
