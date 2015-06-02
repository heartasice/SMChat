
//  XMPPManager.m
//  PrivateChat
//
//  Created by Eric Che on 12/18/14.
//  Copyright (c) 2014 Eric Che. All rights reserved.
//

#import "XMPPManager.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPLogging.h"


#import <AudioToolbox/AudioToolbox.h>

#import "XMPPMessage+XEP_0184.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


static NSString *const XMPPHOST=@"114.215.145.244";


@implementation XMPPManager
+(XMPPManager *)sharedManager
{
    static XMPPManager *_share=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share=[[XMPPManager alloc] init];
    });
    return _share;
}
-(id)init
{
    if (self=[super init]) {
        [self setupStream];
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    }
    return self;
}
- (void)setupStream
{
    self.xmppStream = [[XMPPStream alloc] init];
    //    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppStream setHostName:XMPPHOST];
    
    [self.xmppStream setHostPort:6222];
    
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
//    self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    //    self.xmppUserCoreDataStorageObject=[[XMPPUserCoreDataStorageObject alloc]init];
    
    
//    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
//    
//    self.xmppRoster.autoFetchRoster = YES;
//    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
//    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
//    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
//    
//    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
//    self.xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
//    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
//    
//    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
//    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [self.xmppReconnect         activate:self.xmppStream];
//    [self.xmppRoster            activate:self.xmppStream];
//    [self.xmppvCardTempModule   activate:self.xmppStream];
//    [self.xmppvCardAvatarModule activate:self.xmppStream];
//    [self.xmppCapabilities      activate:self.xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    
//    //创建消息保存策略（规则，规定）
//    self.messageStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    //用消息保存策略创建消息保存组件
//    self.xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.messageStorage];
//    self.xmppMessageArchiving.clientSideMessageArchivingOnly=YES;
//    //使组件生效
//    [self.xmppMessageArchiving activate:self.xmppStream];
    
    
    
}
-(void)loginWithUserName:(NSString*)userName setPassword:(NSString*)password{
    self.userName=userName;
    self.password=password;
    [self login];
}
-(void)login
{
    [self connect];
}
-(void)registrationUser
{
    isReg=YES;
    [self connect];
}
- (BOOL)connect
{
    if (self.userName == nil) {
        if (self.xmppStream.isConnected) {
            [self disconnect];
        }
        return NO;
    }
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
//    [self.xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.userName,@"of.hfdoctors"] resource:@"doctor"]];
//    [self.xmppStream setMyJID:[XMPPJID jidWithString:self.userName resource:XMPPHOST]];
    XMPPJID *jid=[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.userName,XMPPHOST]];
         [self.xmppStream setMyJID:jid];
//
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:20 error:&error])
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
//                                                            message:@"无法连接聊天服务器，请稍后重试"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
        
        return NO;
    }
    return YES;
}

-(void)disconnect{
    [self.xmppStream disconnect];
}
- (void)xmppStreamWillConnect:(XMPPStream *)sender{
    //应该处理 连接服务器
//    [JDStatusBarNotification showWithStatus:@"连接中"];
}
//成功连接服务器
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}
//连接服务器失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    
//    AppDelegate *app=(AppDelegate*)[UIApplication sharedApplication].delegate;
//    if (app.userInfo.count>0) {
//        [JDStatusBarNotification showWithStatus:NETWORK_ERROR];
//         [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_NETWORK_ERROR object:nil];
//    }
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSError *error = nil;
    if (isReg)
    {
        if (![self.xmppStream registerWithPassword:self.password error:&error])
        {
            
        }
    }
    else
    {
        if (![self.xmppStream authenticateWithPassword:self.password error:&error])
        {
            DDLogCError(@"authentication error %@",error);
            
        }
    }
    
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录成功"
    //                                                        message:@"登录成功"
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"Ok"
    //                                              otherButtonTitles:nil];
    //    [alertView show];
}
//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码错误"
//                                                        message:@"密码错误"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
    
    
}
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册成功"
//                                                        message:@"注册成功"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
    isReg=NO;
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    NSLog(@"%@",[[error elementForName:@"error"] stringValue]);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
//                                                        message:@"注册失败"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
    isReg=NO;
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [self.xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
//    NSString *deviceToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
//    if(deviceToken){
//        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"urn:xmpp:apns"];
//        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
//        NSXMLElement *token = [NSXMLElement elementWithName:@"token"];
//        //    XMPPJID *myJID = self.xmppStream.myJID;
//        [iq addAttributeWithName:@"type" stringValue:@"set"];
//        [iq addAttributeWithName:@"id" stringValue:@""];
//        
//        [token setStringValue:deviceToken];
//        [query addChild:token];
//        
//        [iq addChild:query];
//        [self.xmppStream sendElement:iq];
//    }
    
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"com.smartcoder.privatechat.loginsuccess" object:nil];
}
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:presence];
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}

//- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
////    <message type="chat" to="test@114.215.145.244"><body>haha</body></message>
//
//     NSString *body = [[message elementForName:@"body"] stringValue];
//    XMPPUserCoreDataStorageObject *userTo = [self.xmppRosterStorage userForJID:[message to]
//                                                                    xmppStream:self.xmppStream
//                                                          managedObjectContext:[self managedObjectContext_roster]];
//
//
//
//
//    NSManagedObjectContext *context = [self.messageStorage mainThreadManagedObjectContext];
//
//
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
//                                                         inManagedObjectContext:context];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
//    [fetchRequest setEntity:entityDescription];
//
//     NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:context];
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:message. forKey:@"timestamp"];
//    [newManagedObject setValue:message.sender forKeyPath:@"sender"];
//    [newManagedObject setValue:message.text forKeyPath:@"text"];
//
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//- (NSManagedObjectContext *)managedObjectContext_roster
//{
//    //   return  [self.xmppRosterStorage managedObjectModel];
//    return [self.xmppRosterStorage mainThreadManagedObjectContext];
//}
//
//- (NSManagedObjectContext *)managedObjectContext_capabilities
//{
//    return [self.xmppCapabilitiesStorage mainThreadManagedObjectContext];
//}

//添加好友

//在次处理加好友
#pragma mark 收到好友上下线状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
//    AppDelegate *app=(AppDelegate*)[UIApplication sharedApplication].delegate;
//
//    if (app.isLogin) {
//        NSString *from=[presence fromStr];
//        from=[[from componentsSeparatedByString:@"@"]objectAtIndex:0];
//        
//        from=[from substringFromIndex:1];
//        
//        NSString *doctor_id=[app.userInfo objectForKey:@"doctor_id"];
//        if ([doctor_id isEqualToString:from]) {
//            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"您的帐号在别处登录了，如果不是您本人操作，请联系客服。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            [self.xmppStream disconnect];
//            app.window.rootViewController=app.loginNav;
//        }
//    }
//    
//    app.isLogin=YES;
    
//    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
//    //    DDLogVerbose(@"%@: %@ ^^^ %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
//    
//    //取得好友状态
//    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
//    //当前用户
//    //    NSString *userId = [NSString stringWithFormat:@"%@", [[sender myJID] user]];
//    //在线用户
//    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//    NSLog(@"presenceType:%@",presenceType);
//    NSLog(@"用户:%@",presenceFromUser);
//    //这里再次加好友
//    if ([presenceType isEqualToString:@"subscribed"]) {
//        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
////        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
//    }
}
#pragma mark 删除好友,取消加好友，或者加好友后需要删除
- (void)removeBuddy:(NSString *)name
{
//    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,XMPPHOST]];
//    [self.xmppRoster removeUser:jid];
}


- (void)sendMessage:(NSString*)txt toUser:(NSString*)user
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:user]];
    [message addAttributeWithName:@"from" stringValue:self.xmppStream.myJID.bare];
    [message addBody:txt];
    //    [self.xmppStream sendElement:message];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"---%s---%@",__FUNCTION__,message.description);
    if ([message isChatMessageWithBody]){
        
//        NSNotification *noti=[[NSNotification alloc]initWithName:NOTI_SEND_MESSAGE object:message userInfo:nil];
//        [[NSNotificationQueue defaultQueue] enqueueNotification:noti postingStyle:NSPostASAP];
    }
    
    //    if ([message isChatMessageWithBody])
    //    {
    //       [self.messageStorage archiveMessage:message outgoing:YES xmppStream:self.xmppStream];
    //    }
}
-(NSString *)getJidStrWithoutResource:(NSString *)target;
{
    NSRange range=[target rangeOfString:@"/"];
    if(range.location!=NSNotFound)
    {
        target=[target substringToIndex:range.location];
    }
    return target;
}

-(NSDate *)getDelayStampTime:(XMPPMessage *)message
{
    XMPPElement *delay=(XMPPElement *)[message elementForName:@"delay"];
    if (delay) {
        NSString *timeString=[[(XMPPElement *)[message elementForName:@"delay"] attributeForName:@"stamp"] stringValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSArray *arr=[timeString componentsSeparatedByString:@"T"];
        NSString *dateStr=[arr objectAtIndex:0];
        NSString *timeStr=[[[arr objectAtIndex:1] componentsSeparatedByString:@"."] objectAtIndex:0];
        NSDate *localDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@T%@+0000",dateStr,timeStr]];
        return localDate;
    }else{
        return nil;
    }
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
   
    if ([message isChatMessageWithBody]){
        
    }
}

@end
