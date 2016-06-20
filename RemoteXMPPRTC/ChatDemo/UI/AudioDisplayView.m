//
//  AudioDisplayView.m
//  FreeChat
//
//  Created by Harvey on 15/8/30.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import "AudioDisplayView.h"
#import "UIViewExt.h"

@implementation AudioDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        lastVolumn = 1;
        self.backgroundColor = RGBColor(200, 200, 200, 0.6);
        waveImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        waveImage.size = CGSizeMake(frame.size.width-40,frame.size.height-40);
        waveImage.center = self.center;
        [self addSubview:waveImage];
        [self updateAudioWave];
    }
    return self;
}

- (void)updateAudioWave
{
    waveImage.image =[UIImage imageNamed:[NSString stringWithFormat:@"greenVolume0%d",lastVolumn]];
    lastVolumn ++;
    if (lastVolumn > 7) {
        lastVolumn = 1;
    }
}

@end
