//
//  YYFaceScrollView.m
//  ismarter2.0_sz
//
//  Created by zx_04 on 15/6/15.
//
//

#import "FaceScrollView.h"

@implementation FaceScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (id)initWithSelectBlock:(SelectBlock)block
{
    self = [self initWithFrame:CGRectZero];
    if (self != nil) {
        faceView.block = block;
    }
    return self;
}

- (void)initViews
{
    //顶部的分隔线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    topLineView.backgroundColor = [UIColor grayColor];
    topLineView.alpha = 0.3;
    [self addSubview:topLineView];
    
    faceView = [[FaceView alloc] initWithFrame:CGRectZero];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, faceView.height)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(faceView.width, faceView.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.clipsToBounds = NO;
    scrollView.delegate = self;
    
    [scrollView addSubview:faceView];
    [self addSubview:scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollView.bottom, 40, 20)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = faceView.pageNumber;
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
    
    [self addbottomView];
    
    self.height = scrollView.height + pageControl.height + 10 +bottomView.height;
    self.width = scrollView.width;
}

- (void)addbottomView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, pageControl.bottom+10, 320, 35)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    
    UIView *topLine =[[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.width, 0.5)];
    topLine.backgroundColor = [UIColor grayColor];
    [bottomView addSubview:topLine];
    
    UIButton *smallemoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bottomView.height, bottomView.height)];
    smallemoBtn.backgroundColor = [UIColor clearColor];
    [smallemoBtn setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    //    [smallemoBtn addTarget:self action:@selector(changeForEmotion) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:smallemoBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(smallemoBtn.right +5, 5, 0.5, bottomView.height - 10)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:lineView];
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-60, 0, 60, bottomView.height)];
    [sendBtn setImage:[UIImage imageNamed:@"chat_send_button"] forState:UIControlStateNormal];
    [sendBtn setImage:[UIImage imageNamed:@"chat_send_buttonHL"] forState:UIControlStateHighlighted];
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sendBtn];
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView;
{
    int pageNumber = _scrollView.contentOffset.x/320;
    pageControl.currentPage = pageNumber;
}

- (void)sendBtnClick
{
    if (_sendBlock) {
        _sendBlock();
    }
}

@end
