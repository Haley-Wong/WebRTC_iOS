//
//  RTCContants.h
//  ChatDemo
//
//  Created by Harvey on 16/6/2.
//  Copyright © 2016年 Mac. All rights reserved.
//

#ifndef RTCContants_h
#define RTCContants_h

#import <Foundation/Foundation.h>

#error 这里需要设置你们的房间服务器地址、STUN服务器地址、TURN服务器地址
// 房间服务器
NSString *const RTCRoomServerURL = @"";

//STUN服务器
NSString *const RTCSTUNServerURL = @"";

//NSString * const RTCSTUNServerURL = @"stun:stun.l.google.com:19302";

//TRUN服务器
NSString *const RTCTRUNServerURL = @"";

static NSString const *kARDJoinResultKey = @"result";
static NSString const *kARDJoinResultParamsKey = @"params";
static NSString const *kARDJoinInitiatorKey = @"is_initiator";
static NSString const *kARDJoinRoomIdKey = @"room_id";
static NSString const *kARDJoinClientIdKey = @"client_id";
static NSString const *kARDJoinMessagesKey = @"messages";
static NSString const *kARDJoinWebSocketURLKey = @"wss_url";
static NSString const *kARDJoinWebSocketRestURLKey = @"wss_post_url";

#endif /* RTCContants_h */
