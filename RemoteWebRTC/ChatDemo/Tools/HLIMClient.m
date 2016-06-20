//
//  HLIMClient.m
//  ChatDemo
//
//  Created by Harvey on 16/3/3.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "HLIMClient.h"
#import "HLIMCenter.h"

@implementation HLIMClient

static HLIMClient *_instance;

/**
 *  API调用单例
 *
 *  @return 返回一个单例对象
 */
+ (instancetype)shareClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [HLIMClient new];
    });
    
    return _instance;
}

#pragma mark - override method
- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 接口API 
/**
 *  登录接口
 *
 *  @param username     用户名，目前用jid
 *  @param password     密码
 *  @param successBlock 成功回调
 *  @param failureBlock 失败回调
 */
- (void)login:(NSString *)username
     password:(NSString *)password
      success:(void (^)(NSString *userId))successBlock
      failure:(void (^)(NSDictionary *errorDict))failureBlock
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance] loginWithJID:JID andPassword:password success:successBlock failture:failureBlock];
}

/**
 *  注销登录
 */
- (void)logout
{
    [[HLIMCenter sharedInstance] logout];
}

/**
 *  注册接口
 *
 *  @param JID      账号jid
 *  @param password 密码
 */
- (void)registerUser:(NSString *)username
            password:(NSString *)password
             success:(void (^)(void))successBlock
            failture:(void (^)(NSDictionary *errorDict))failureBlock
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance] registerWithJID:JID andPassword:password success:successBlock failture:failureBlock];
}

#pragma mark - Roster
/**
 *  发送加好友申请
 *
 *  @param jid    对方的username
 *  @param reason 发送
 */
- (void)addUser:(NSString *)username reason:(NSString *)reason
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance].xmppRoster addUser:JID withNickname:nil];
}

/**
 *  获取好友列表
 *
 *  @return 好友数组
 */
- (NSArray *)getUsers
{
    return [HLIMCenter sharedInstance].xmppRosterMemoryStorage.sortedUsersByAvailabilityName;
}

/**
 *  接受对方的好友请求
 *
 *  @param username  对方的username
 *  @param flag 是否同时请求加对方为好友，YES:请求加对方，NO:不请求加对方
 */
- (void)acceptAddRequestFrom:(NSString *)username andAddRoster:(BOOL)flag
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance].xmppRoster acceptPresenceSubscriptionRequestFrom:JID andAddToRoster:flag];
}

/**
 *  拒绝对方的好友请求
 *
 *  @param username 对方的username
 */
- (void)rejectAddRequestFrom:(NSString*)username
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance].xmppRoster rejectPresenceSubscriptionRequestFrom:JID];
}

/**
 *  删除某个好友
 *
 *  @param username 要删除好友的username
 */
- (void)removeUser:(NSString*)username
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance].xmppRoster removeUser:JID];
}

/**
 *  为好友设置备注
 *
 *  @param nickname 备注
 *  @param username      好友的username
 */
- (void)setNickname:(NSString *)nickname forUser:(NSString *)username
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    [[HLIMCenter sharedInstance].xmppRoster setNickname:nickname forUser:JID];
}

#pragma mark - 单聊
/**
 *  发送文字消息
 *
 *  @param message  文本
 *  @param username 对方的username
 */
- (void)sendMessage:(NSString *)text toUser:(NSString *)username
{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:@"suneeedev" resource:@"iOS"];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:JID];
    [message addBody:text];
    [[HLIMCenter sharedInstance].xmppStream sendElement:message];

}

- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)jidStr
{
    XMPPJID *JID = [XMPPJID jidWithString:jidStr];
    
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:JID];
    [xmppMessage addBody:message];
    
    [[HLIMCenter sharedInstance].xmppStream sendElement:xmppMessage];
}


@end
