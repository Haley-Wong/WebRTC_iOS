//
//  WebRTCClient.h
//  ChatDemo
//
//  Created by Harvey on 16/5/30.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCView.h"

typedef NS_ENUM(NSInteger, ARDSignalingChannelState) {
    // State when disconnected.
    kARDSignalingChannelStateClosed,
    // State when connection is established but not ready for use.
    kARDSignalingChannelStateOpen,
    // State when connection is established and registered.
    kARDSignalingChannelStateRegistered,
    // State when connection encounters a fatal error.
    kARDSignalingChannelStateError
};

@interface WebRTCClient : NSObject

@property (strong, nonatomic)   RTCView            *rtcView;

@property (copy, nonatomic)     NSString            *myJID;  /**< 自己的JID */
@property (copy, nonatomic)     NSString            *remoteJID;    /**< 对方JID */

@property (copy, nonatomic) NSString            *roomId;    /** 房间号，用完需要清空 */
@property (copy, nonatomic) NSString            *clientId;    /**< 客户端id, 用完需要清空 */

+ (instancetype)sharedInstance;

+ (NSString *)randomRoomId;

- (void)startEngine;

- (void)stopEngine;

- (void)showRTCViewByRemoteName:(NSString *)remoteName isVideo:(BOOL)isVideo isCaller:(BOOL)isCaller;

- (void)resizeViews;

@end
