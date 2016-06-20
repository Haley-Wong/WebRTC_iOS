//
//  JKXMPPTool.h
//  ChatDemo
//
//  Created by Joker on 15/7/19.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const  kReceivedSinalingMessageNotification;


typedef void(^LoginSuccess)(NSString *userId);
typedef void(^LoginFailture)(NSDictionary *errorDict);
typedef void(^RegisterSuccess)(void);
typedef void(^RegisterFailture)(NSDictionary *errorDict);

@interface HLIMCenter : NSObject

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;

@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (nonatomic, strong, readonly) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

@property (nonatomic, assign) BOOL  xmppNeedRegister;

/** 工具类 */
+ (instancetype)sharedInstance;

/**
 *  登录接口
 *
 *  @param JID      账号jid
 *  @param password 密码
 */
- (void)loginWithJID:(XMPPJID *)JID andPassword:(NSString *)password success:(LoginSuccess)success failture:(LoginFailture)failture;

/**
 *  注册接口
 *
 *  @param JID      账号jid
 *  @param password 密码
 */
- (void)registerWithJID:(XMPPJID *)JID andPassword:(NSString *)password success:(RegisterSuccess)success failture:(RegisterFailture)failture;

/**
 *  退出登录
 */
- (void)logout;

@end
