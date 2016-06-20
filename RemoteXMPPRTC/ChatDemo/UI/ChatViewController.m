//
//  ChatViewController.m
//  ChatDemo
//
//  Created by Joker on 15/7/22.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "ChatViewController.h"

#import "HLIMCenter.h"
#import "HLIMClient.h"
#import "WebRTCClient.h"

#import "FaceScrollView.h"
#import "AudioDisplayView.h"
#import "UIViewExt.h"
#import "SVProgressHUD.h"

#define kHeightOfMoreView           200         //更多视图的高度
#define kHeightOfInputView          49          //输入视图的高度

@interface ChatViewController ()<XMPPOutgoingFileTransferDelegate,UITextViewDelegate>
{
    AudioDisplayView                    *audioDisplayView;
    NSTimer                             *recordTimer;
    float                               timesCount;
    int                                 recordAudioSeconds;
}

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

/** 工具栏视图 ，如拍照、图片、视频、位置、名片按钮*/
@property (nonatomic, retain) UIView                *toolView;
/** 键盘按钮1 */
@property (nonatomic, retain) UIButton              *keyboardBtn1;
/** 说话按钮 */
@property (nonatomic, retain) UIButton              *audioButton;
/** 按住说话按钮 */
@property (nonatomic, retain) UIButton              *talkButton;
/** 文本框 */
@property (nonatomic, retain) UITextView            *textView;
/** 键盘按钮2 */
@property (nonatomic, retain) UIButton              *keyboardBtn;
/** 表情按钮 */
@property (nonatomic, retain) UIButton              *emoButton;
/** 更多功能按钮 */
@property (nonatomic, retain) UIButton              *moreButton;
/** 表情视图 */
@property (nonatomic, retain) FaceScrollView        *faceView;

@property (nonatomic, retain) AVAudioRecorder   *recorder;
@property (nonatomic, retain) AVAudioPlayer     *player;

@property (nonatomic, strong) XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _chatJID.user;
    
    self.view.backgroundColor = RGBColor(234, 239, 245, 1);
    
    [self addNotifications];
    
    [self initTableView];
    
    [self _initBottomView];
    
    [self _initToolView];
    
    [self getChatHistory];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatHistory) name:kXMPP_MESSAGE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillSHow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initTableView
{
    self.messageTableView.rowHeight = 60;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [_messageTableView addGestureRecognizer:tapGesture];
}

/** 初始化输入框视图 */
- (void)_initBottomView
{
    /*按住说话时 出现的录音效果视图*/
    audioDisplayView = [[AudioDisplayView alloc] initWithFrame:CGRectMake(0, 0, 132,77)];
    audioDisplayView.center = self.view.center;
    audioDisplayView.hidden = YES;
    [self.view addSubview:audioDisplayView];
    
    
    //顶部的分隔线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    topLineView.backgroundColor = TABLEVIEW_BORDER_COLOR;
    [_bottomView addSubview:topLineView];
    
    //键盘按钮1
    _keyboardBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    _keyboardBtn1.alpha = 0;
    [_keyboardBtn1 setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [_keyboardBtn1 setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
    [_keyboardBtn1 addTarget:self action:@selector(keyboardBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_keyboardBtn1];
    
    //语音按钮
    _audioButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    [_audioButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
    [_audioButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    [_audioButton addTarget:self action:@selector(audioAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_audioButton];
    
    //按住说话按钮
    _talkButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 6, kScreenWidth-50-85, 37)];
    [_talkButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [_talkButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageNamed:@"record_bgImage"] forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageNamed:@"record_bgImageHL"] forState:UIControlStateHighlighted];
    [_talkButton addTarget:self action:@selector(talkTouchDownAction) forControlEvents:UIControlEventTouchDown];
    [_talkButton addTarget:self action:@selector(talkTouchUpAction) forControlEvents:UIControlEventTouchUpInside];
    [_talkButton addTarget:self action:@selector(talkTouchUpAction) forControlEvents:UIControlEventTouchDragExit];
    _talkButton.hidden = YES;
    [_bottomView addSubview:_talkButton];
    
    //文字输入框
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(50, 6, kScreenWidth-50-85, 37)];
    _textView.layer.cornerRadius = 5.0f;
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.borderColor = TABLEVIEW_BORDER_COLOR.CGColor;
    _textView.layer.masksToBounds = YES;
    _textView.font = [UIFont systemFontOfSize:17.0f];
    _textView.showsVerticalScrollIndicator = NO;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    [_bottomView addSubview:_textView];
    
    //键盘按钮2
    _keyboardBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 40, 40)];
    _keyboardBtn.alpha = 0;
    [_keyboardBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [_keyboardBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
    [_keyboardBtn addTarget:self action:@selector(keyboardBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_keyboardBtn];
    
    //表情按钮
    _emoButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 40, 40)];
    [_emoButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
    [_emoButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    [_emoButton addTarget:self action:@selector(emoAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_emoButton];
    
    //更多功能按钮
    _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 5, 40, 40)];
    [_moreButton setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"add_icon_on"] forState:UIControlStateHighlighted];
    [_moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_moreButton];
}

/** 初始化更多功能视图 */
- (void)_initToolView
{
    _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottomView.bottom, kScreenWidth, kHeightOfMoreView)];
    _toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolView];
    
    //顶部分隔线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    topLineView.backgroundColor = TABLEVIEW_BORDER_COLOR;
    [_toolView addSubview:topLineView];
    
    NSArray *images = @[@"chat_more_pic",@"chat_more_recordVideo",@"chat_more_shortVideo",@"chat_more_videoChat",@"chat_more_voiceChat",@"chat_more_card",@"chat_more_location",@"chat_more_file"];
    NSArray *imageHLs = @[@"chat_more_picHL",@"chat_more_recordVideoHL",@"chat_more_shortVideoHL",@"chat_more_videoChatHL",@"chat_more_voiceChatHL",@"chat_more_cardHL",@"chat_more_locationHL",@"chat_more_fileHL"];
    
    CGFloat btnWidth = 60;
    CGFloat kpadding = (kScreenWidth - btnWidth*4)/5;
    for (int i = 0; i<images.count; i++) {
        int rowNum = i/4;
        int colNum = i%4;
        
        CGRect rect = CGRectMake(kpadding+(kpadding+btnWidth)*colNum, 20+rowNum*85, btnWidth, btnWidth);
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        button.layer.cornerRadius = 5.0f;
        button.layer.borderColor = TABLEVIEW_BORDER_COLOR.CGColor;
        button.layer.borderWidth = 0.5f;
        button.tag = 1000+i;
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imageHLs[i]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:button];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPP_MESSAGE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_xmppOutgoingFileTransfer removeDelegate:self];
    [_xmppOutgoingFileTransfer deactivate];
    _xmppOutgoingFileTransfer = nil;
}

- (void)startCommunication:(BOOL)isVideo
{
    WebRTCClient *client = [WebRTCClient sharedInstance];
    client.myJID = [HLIMCenter sharedInstance].xmppStream.myJID.full;
    client.remoteJID = self.chatJID.full;
    
    [client showRTCViewByRemoteName:self.chatJID.full isVideo:isVideo isCaller:YES];
}

#pragma mark - private method
/** 发送的事件 */
- (void)sendMessage:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length <= 0) {
        return;
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [message addBody:text];
    [[HLIMCenter sharedInstance].xmppStream sendElement:message];
    
    [self tableViewScrollToBottom];
}

/** 查询聊天记录 */
- (void)getChatHistory
{
    XMPPMessageArchivingCoreDataStorage *storage = [HLIMCenter sharedInstance].xmppMessageArchivingCoreDataStorage;
    //查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil) {
        self.chatHistory = [[NSMutableArray alloc] initWithArray:fetchedObjects];
        //        [NSMutableArray arrayWithArray:fetchedObjects];
    }
    
    [self.messageTableView reloadData];
    
    [self tableViewScrollToBottom];
}

- (void)tableViewScrollToBottom
{
    if (_chatHistory.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_chatHistory.count-1) inSection:0];
        [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)showHUDFailed:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}

- (XMPPOutgoingFileTransfer *)xmppOutgoingFileTransfer
{
    if (!_xmppOutgoingFileTransfer) {
        _xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        [_xmppOutgoingFileTransfer activate:[HLIMCenter sharedInstance].xmppStream];
        [_xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _xmppOutgoingFileTransfer;
}

- (void)playVoice:(UIButton *)btn
{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.chatHistory[btn.tag];
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:message.body];
    NSURL *url = [NSURL URLWithString:path];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player prepareToPlay];
    [self.player play];
}

/** 开始录音 */
- (IBAction)startRecord:(id)sender {
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:@"wav"];
    
    NSURL *URL = [NSURL fileURLWithPath:path];
    _recorder = [[AVAudioRecorder alloc] initWithURL:URL settings:nil error:nil];
    [_recorder prepareToRecord];
    [_recorder record];
}

- (IBAction)sendRecord:(id)sender {
    [_recorder stop];
    NSArray *resources = [[HLIMCenter sharedInstance].xmppRosterMemoryStorage sortedResources:YES];
    for (XMPPResourceMemoryStorageObject *object in resources) {
        if ([object.jid.bare isEqualToString:self.chatJID.bare]) {
            NSData *data = [[[NSData alloc] initWithContentsOfURL:_recorder.url] copy];
            NSError *err;
            [self.xmppOutgoingFileTransfer sendData:data named:_recorder.url.lastPathComponent toRecipient:object.jid description:nil error:&err];
            if (err) {
                NSLog(@"%@",err);
            }
            break;
        }
    }
    
    _recorder = nil;
}

/*取消录音*/
- (IBAction)cancelRecord:(id)sender {
    [_recorder stop];
    [[NSFileManager defaultManager] removeItemAtURL:_recorder.url error:nil];
    _recorder = nil;
}

/*定时改变录音动画*/
- (void)changeAudioWaveView:(NSTimer *)timer
{
    timesCount += 0.08;
    if (timesCount - recordAudioSeconds > 1)
    {
        recordAudioSeconds += 1;
        if (recordAudioSeconds > 59)
        {//录制60s 停止录音 自动发送
            [self sendRecord:nil];
            return;
        }
    }
    [audioDisplayView updateAudioWave];
}


/*显示录音动画视图*/
- (void)showAudioDisplayView
{
    [self.view bringSubviewToFront:audioDisplayView];
    [UIView animateWithDuration:0.5 animations:^{
        audioDisplayView.hidden = NO;
    }];
}

/*取消录音动画视图*/
- (void)hiddenAudioDisplayView
{
    [UIView animateWithDuration:0.5 animations:^{
        audioDisplayView.hidden = YES;
    }];
}


/** 重置按钮状态 */
- (void)resetButtons
{
    _keyboardBtn1.alpha = 0;
    _keyboardBtn.alpha = 0;
    _emoButton.alpha = 1;
    _audioButton.alpha = 1;
    
    _textView.hidden = NO;
    _talkButton.hidden = YES;
}

#pragma mark - btn click event 
/** 键盘按钮 */
- (void)keyboardBtnClick
{
    [self.textView becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _faceView.transform = CGAffineTransformTranslate(_faceView.transform, 0, kScreenHeight-44-20);
        [self resetButtons];
    }];
}

/** 表情按钮点击事件 */
- (void)emoAction
{
    [self.textView resignFirstResponder];
    
    NSLog(@"点击了表情");
    
//    if (_faceView == nil) {
//        __block __weak ChatViewController *this = self;
//        _faceView = [[FaceScrollView alloc] initWithSelectBlock:^(NSString *faceName) {
//            NSString *text = this.textView.text;
//            NSString *appendText = [text stringByAppendingString:faceName];
//            this.textView.text = appendText;
//        }];
//        _faceView.backgroundColor = RGBColor(220, 220, 220, 1);
//        _faceView.top = kScreenHeight;
//        _faceView.clipsToBounds = NO;
//        _faceView.sendBlock = ^{
//            NSString* fullText = this.textView.text;
//            [this sendMessage:fullText];
//            this.textView.text = nil;
//        };
//        [self.view addSubview:_faceView];
//    }
//    float height = _faceView.height;
//    //设置键盘动画
//    [UIView animateWithDuration:0.3 animations:^{
//        [self resetButtons];
//        _emoButton.alpha = 0;
//        _keyboardBtn.alpha = 1;
//        _faceView.top = kScreenHeight- height;
//        //调整bottomView的高度
//        self.bottomView.bottom = _faceView.top;
//        // 3、修改表格的高度
//        _messageTableView.height = _bottomView.top;
//    } completion:^(BOOL finished) {
//        if (_toolView.top < kScreenHeight) {
//            _toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kHeightOfMoreView);
//        }
//    }];
}

/** 更多功能按钮点击事件 */
- (void)moreAction
{
    //如果键盘没隐藏，先隐藏键盘
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat y = _toolView.frame.origin.y;
        // 1、修改更多功能视图的位置
        // 2、修改输入框视图的位置
        if (y == kScreenHeight) {
            _toolView.frame = CGRectMake(0, kScreenHeight-kHeightOfMoreView, kScreenWidth, kHeightOfMoreView);
            _bottomView.bottom = kScreenHeight-kHeightOfMoreView;
        } else {
            _toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kHeightOfMoreView);
            _bottomView.bottom = kScreenHeight;
        }
        [self resetButtons];
        // 3、修改表格的高度
        _messageTableView.height = _bottomView.top;
    } completion:^(BOOL finished) {
        _faceView.top = kScreenHeight - 20 - 44;
    }];
}

/** 语音按钮点击事件 */
- (void)audioAction
{
    //1.隐藏键盘、表情、更多视图
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _toolView.top = kScreenHeight;
        _faceView.top = kScreenHeight;
        //2、修复bottom和tableView的位置
        _bottomView.bottom = kScreenHeight;
        _messageTableView.height = _bottomView.top;
        
        _talkButton.hidden = NO;
        _textView.hidden = YES;
        
        //3、修改按钮的现实与隐藏
        _keyboardBtn1.alpha = 1;
        _audioButton.alpha = 0;
        _keyboardBtn.alpha = 0;
        _emoButton.alpha = 1;
    }];
}

- (void)talkTouchDownAction
{
    if (recordTimer != nil) {
        [recordTimer invalidate];
        recordTimer = nil;
    }
    recordAudioSeconds = 0;
    timesCount = 0;
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.08
                                                   target:self
                                                 selector:@selector(changeAudioWaveView:)
                                                 userInfo:nil
                                                  repeats:YES];
    [self showAudioDisplayView];
    [self performSelector:@selector(startRecord:) withObject:nil afterDelay:0];
}

- (void)talkTouchUpAction
{
    NSLog(@"%s",__FUNCTION__);
    [self hiddenAudioDisplayView];
    [self sendRecord:nil];
}


/** 工具条里的按钮点击事件 */
- (void)toolBtnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:  //图库
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1001: //拍照
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1002: //短片
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1003: //视频聊天
        {
            [self startCommunication:YES];
            break;
        }
        case 1004: //语音聊天
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1005: //名片
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1006: //位置
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        case 1007: //文件
        {
            [self showHUDFailed:@"暂未实现"];
            break;
        }
        default:
            break;
    }
}

/** 取消事件的焦点 */
- (void)cancelFocus:(UITapGestureRecognizer *)gesture
{
    [self.messageTableView removeGestureRecognizer:gesture];
    gesture = nil;
    
    [self.textView resignFirstResponder];
    //下面这个动画是修改更多功能的位置，复位问题
    [UIView animateWithDuration:0.3f animations:^{
        // 1、修改更多功能视图的位置
        _toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kHeightOfMoreView);
        // 2、修改表情视图的位置
        _faceView.transform = CGAffineTransformTranslate(_faceView.transform, 0, kScreenHeight);
        // 3、修改输入框视图的位置
        _bottomView.bottom = _toolView.top;
        // 4、修改表格的高度
        _messageTableView.height = _bottomView.top;
        // 5、重置按钮状态
        [self resetButtons];
    }];
}

#pragma mark - notification event
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

- (void)keyboardWillSHow:(NSNotification *)notification
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFocus:)];
    [self.messageTableView addGestureRecognizer:tapGesture];
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        _toolView.top = kScreenHeight;
        _faceView.top = kScreenHeight;
        //1.修改输入框View的位置
        _bottomView.bottom = kScreenHeight-frame.size.height;
        //2.修改tableView的高度
        _messageTableView.height = _bottomView.top;
        //3.重置按钮状态
        [self resetButtons];
    } completion:^(BOOL finished) {
        [self tableViewScrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        _bottomView.transform = CGAffineTransformIdentity;
        CGRect rect = _messageTableView.frame;
        rect.size.height = kScreenHeight-50;
        _messageTableView.frame = rect;
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSString *fullText = textView.text;
        [self sendMessage:fullText];
        textView.text = nil;
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //先判断这个消息显示在哪边
    XMPPMessageArchiving_Message_CoreDataObject *message = self.chatHistory[indexPath.row];
    NSString *identifier = message.isOutgoing?@"TextMessageRight":@"TextMessageLeft";
    if ([message.message.subject isEqualToString:@"audio"]) {
        identifier = message.isOutgoing?@"AudioMessageRight":@"AudioMessageLeft";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        UIButton *btn = (UIButton*)[cell viewWithTag:10002];
        btn.tag = indexPath.row;
        [btn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:10002];
    contentLabel.text = message.body;
    
    return cell;
}

#pragma mark - 文件发送代理
- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError:%@",error);
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
    NSLog(@"xmppOutgoingFileTransferDidSucceed");
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    
    //将这个文件的发送者添加到message的from
    [message addAttributeWithName:@"from" stringValue:[HLIMCenter sharedInstance].xmppStream.myJID.bare];
    [message addSubject:@"audio"];
    
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:sender.outgoingFileName];
    
    [message addBody:path.lastPathComponent];
    
    [[HLIMCenter sharedInstance].xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:[HLIMCenter sharedInstance].xmppStream];
}

@end
