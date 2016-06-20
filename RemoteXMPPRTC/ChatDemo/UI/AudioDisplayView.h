//
//  AudioDisplayView.h
//  FreeChat
//
//  Created by Harvey on 15/8/30.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioDisplayView : UIView
{
    UIImageView *waveImage;
    int lastVolumn;
}

- (void)updateAudioWave;

@end
