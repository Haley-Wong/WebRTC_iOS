//
//  YYFaceScrollView.h
//  ismarter2.0_sz
//
//  Created by zx_04 on 15/6/15.
//
//

#import <UIKit/UIKit.h>
#import "FaceView.h"

//@class YYFaceScrollView;
//@protocol faceScrollViewDelegate <NSObject>
//@optional
//- (void)sendBtnClick:(YYFaceScrollView *)faceScrollView;
//
//@end

typedef void(^SendBtnClickBlock)(void);

@interface FaceScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView    *scrollView;
    FaceView        *faceView;
    UIPageControl   *pageControl;
    UIView          *bottomView;
}

@property (nonatomic, copy)     SendBtnClickBlock           sendBlock;

- (id)initWithSelectBlock:(SelectBlock)block;

@end
