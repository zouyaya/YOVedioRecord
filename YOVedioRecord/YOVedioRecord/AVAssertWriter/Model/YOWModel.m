//
//  YOWModel.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOWModel.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YOFileManager.h"
#import "AVAssertWriterManager.h"

@interface YOWModel ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVAssertWriterManagerDelegate>

@property (weak, nonatomic) UIView *superView;

@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) dispatch_queue_t vedioQuenu;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewlayer;

@property (strong, nonatomic) AVCaptureDeviceInput *vedioInput;

@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;

@property (strong, nonatomic) AVCaptureVideoDataOutput *vedioOutPut;

@property (strong, nonatomic) AVCaptureAudioDataOutput *audioOutPut;

@property (strong, nonatomic) AVAssertWriterManager *writeManager;

@property (strong, nonatomic,readwrite) NSURL *vedioUrl;

@property (assign, nonatomic) YOFlashState flashState;

@property (assign, nonatomic) YOASVedioViewType viewType;


@end

@implementation YOWModel

-(instancetype)initWithFMVideoViewType:(YOASVedioViewType)type superView:(UIView *)superView
{
    self = [super init];
    if (self) {
        
        _superView = superView;
        _viewType = type;
        [self setUpwithType:type];
    }
    
    return self;

}

-(void)setUpwithType:(YOASVedioViewType)type
{
    
    ///1. 初始化捕捉会话，数据的采集都在会话中处理
    [self setUpInit];
    
    ///2. 设置视频的输入输出
    [self setUpVideo];
    
    ///3. 设置音频的输入输出
    [self setUpAudio];
    
    ///4. 视频的预览层
    [self setUpPreviewLayerWithType:type];
    
    
    ///5. 开始采集画面
    [self.session startRunning];
    
    /// 6. 初始化writer， 用writer 把数据写入文件
    [self setUpWriter];
    
}

#pragma mark - private method
//初始化设置
- (void)setUpInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self clearFile];
    _recordState = YOASRecordStateInit;
}

//存放视频的文件夹
- (NSString *)videoFolder
{
    NSString *cacheDir = [YOFileManager cachesDir];
    NSString *direc = [cacheDir stringByAppendingPathComponent:@"videoFolder"];
    if (![YOFileManager isExistsAtPath:direc]) {
        [YOFileManager createDirectoryAtPath:direc];
    }
    return direc;
}
//清空文件夹
- (void)clearFile
{
    [YOFileManager removeItemAtPath:[self videoFolder]];
    
}
//写入的视频路径
- (NSString *)createVideoFilePath
{
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
    
}


- (void)setUpVideo
{
    // 2.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    // 2.2 创建视频输入源
    NSError *error=nil;
    self.vedioInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    // 2.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.vedioInput]) {
        [self.session addInput:self.vedioInput];
    }
    
    self.vedioOutPut = [[AVCaptureVideoDataOutput alloc] init];
    self.vedioOutPut.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    [self.vedioOutPut setSampleBufferDelegate:self queue:self.vedioQuenu];
    if ([self.session canAddOutput:self.vedioOutPut]) {
        [self.session addOutput:self.vedioOutPut];
    }
    
}

- (void)setUpAudio
{
    // 2.2 获取音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    // 2.4 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    // 2.6 将音频输入源添加到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    self.audioOutPut = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutPut setSampleBufferDelegate:self queue:self.vedioQuenu];
    if([self.session canAddOutput:self.audioOutPut]) {
        [self.session addOutput:self.audioOutPut];
    }
    
}

- (void)setUpPreviewLayerWithType:(YOASVedioViewType)type
{
    CGRect rect = CGRectZero;
    switch (type) {
        case YOASVedioViewType1X1:
            rect = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            break;
        case YOASVedioViewType4X3:
            rect = CGRectMake(0, 0, ScreenWidth, ScreenWidth*4/3);
            break;
        case YOASVedioViewTypeFullScreen:
            rect = [UIScreen mainScreen].bounds;
            break;
        default:
            rect = [UIScreen mainScreen].bounds;
            break;
    }
    
    self.previewlayer.frame = rect;
    [_superView.layer insertSublayer:self.previewlayer atIndex:0];
}

- (void)setUpWriter
{
    self.vedioUrl = [[NSURL alloc] initFileURLWithPath:[self createVideoFilePath]];
    self.writeManager = [[AVAssertWriterManager alloc] initWithURL:self.vedioUrl viewType:_viewType];
    self.writeManager.delegate = self;
    
}


#pragma mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        //视频
        if (connection == [self.vedioOutPut connectionWithMediaType:AVMediaTypeVideo]) {
            
            if (!self.writeManager.outputVideoFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputVideoFormatDescription = formatDescription;
                }
            } else {
                @synchronized(self) {
                    if (self.writeManager.writeState == YOASRecordStateRecording) {
                        [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                    }
                    
                }
            }
            
            
        }
        
        //音频
        if (connection == [self.audioOutPut connectionWithMediaType:AVMediaTypeAudio]) {
            if (!self.writeManager.outputAudioFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputAudioFormatDescription = formatDescription;
                }
            }
            @synchronized(self) {
                
                if (self.writeManager.writeState == YOASRecordStateRecording) {
                    [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                }
                
            }
            
        }
    }
    
}

#pragma mark - public method
//切换摄像头
- (void)turnCameraAction
{
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.vedioInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];
    
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.vedioInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.vedioInput = newInput;
    
    [self.session startRunning];
    
}


- (void)switchflash
{
    if(_flashState == YOFlashStateClose){
        if ([self.vedioInput.device hasTorch]) {
            [self.vedioInput.device lockForConfiguration:nil];
            [self.vedioInput.device setTorchMode:AVCaptureTorchModeOn];
            [self.vedioInput.device unlockForConfiguration];
            _flashState = YOFlashStateOpen;
        }
    }else if(_flashState == YOFlashStateOpen){
        if ([self.vedioInput.device hasTorch]) {
            [self.vedioInput.device lockForConfiguration:nil];
            [self.vedioInput.device setTorchMode:AVCaptureTorchModeAuto];
            [self.vedioInput.device unlockForConfiguration];
            _flashState = YOFlashStateAuto;
        }
    }else if(_flashState == YOFlashStateAuto){
        if ([self.vedioInput.device hasTorch]) {
            [self.vedioInput.device lockForConfiguration:nil];
            [self.vedioInput.device setTorchMode:AVCaptureTorchModeOff];
            [self.vedioInput.device unlockForConfiguration];
            _flashState = YOFlashStateClose;
        }
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateFlashState:)]) {
        [self.delegate updateFlashState:_flashState];
    }
    
}


- (void)startRecord
{
    if (self.recordState == YOASRecordStateInit) {
        [self.writeManager startWrite];
        self.recordState = YOASRecordStateRecording;
    }
}

- (void)stopRecord
{
    
    [self.writeManager stopWrite];
    [self.session stopRunning];
    self.recordState = YOASRecordStateFinish;
    
}

- (void)reset
{
    self.recordState = YOASRecordStateInit;
    [self.session startRunning];
    [self setUpWriter];
    
}


#pragma mark - AVAssetWriteManagerDelegate
- (void)updateWritingProgress:(CGFloat)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
        [self.delegate updateRecordingProgress:progress];
    }
}

- (void)finishWriting
{
    [self.session stopRunning];
    self.recordState = YOASRecordStateFinish;
}


#pragma mark - notification
- (void)enterBack
{
    self.vedioUrl = nil;
    [self.session stopRunning];
    [self.writeManager destroyWrite];
    
}

- (void)becomeActive
{
    [self reset];
}


- (void)destroy
{
    [self.session stopRunning];
    self.session = nil;
    self.vedioQuenu = nil;
    self.vedioOutPut = nil;
    self.vedioInput = nil;
    self.audioOutPut = nil;
    self.audioInput = nil;
    [self.writeManager destroyWrite];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self destroy];
    
}

#pragma mark-------k懒加载
-(AVCaptureSession *)session
{
    // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
    // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
    // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    
    return _session;
    
}


-(dispatch_queue_t)vedioQuenu
{
    if (!_vedioQuenu) {
        _vedioQuenu = dispatch_queue_create("com.5miles", DISPATCH_QUEUE_SERIAL);
    }
    return _vedioQuenu;
    
}

-(AVCaptureVideoPreviewLayer *)previewlayer
{
    if (!_previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _previewlayer;
}

-(void)setRecordState:(YOASRecordState)recordState
{
    if (_recordState != recordState) {
        
        _recordState = recordState;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
            [self.delegate updateRecordState:_recordState];
        }
    }
    
    
}

@end
