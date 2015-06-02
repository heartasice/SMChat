//
//  XMPPManager.h
//  PrivateChat
//
//  Created by Eric Che on 12/18/14.
//  Copyright (c) 2014 Eric Che. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPFramework.h"
#import "XMPPReconnect.h"

@interface XMPPManager : NSObject<XMPPStreamDelegate>{
    BOOL isReg;
}

@property(nonatomic,strong)XMPPStream *xmppStream;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)XMPPReconnect *xmppReconnect;

+(XMPPManager *)sharedManager;
-(void)loginWithUserName:(NSString*)userName setPassword:(NSString*)password;
-(void)login;
-(void)registrationUser;

- (void)goOffline;
- (void)goOnline;
- (void)sendMessage:(NSString*)txt toUser:(NSString*)user;
@end
