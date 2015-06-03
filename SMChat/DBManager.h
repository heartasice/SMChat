//
//  DBManager.h
//  SMChat
//
//  Created by Eric Che on 2/6/15.
//  Copyright (c) 2015 Eric Che. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMChatMessageModel.h"
#import "FMDB.h"
@interface DBManager : NSObject
+(FMDatabaseQueue *)sharedDatabaseQueue;
+(NSInteger)addChatMessage:(SMChatMessageModel*)chatMessageModel;
+(NSArray*)getChatMessageByCurrentUserId:(NSString*)currentUserId setToUserId:(NSString*)toUserId setPageIndex:(NSNumber*)pageIndex setPageSize:(NSNumber*)pageSize;
@end
