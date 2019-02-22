//
//  AVAssertWriterManager.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import "AVAssertWriterManager.h"
#import "YOFileManager.h"
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVAssertWriterManager ()


@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) NSURL           *videoUrl;

@property (nonatomic, strong)AVAssetWriter *assetWriter;

@property (nonatomic, strong)AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong)AVAssetWriterInput *assetWriterAudioInput;



@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;


@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, assign) YOASVedioViewType viewType;
@property (nonatomic, assign) CGSize outputSize;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat recordTime;


@end

@implementation AVAssertWriterManager

- (void)setUpInitWithType:(YOASVedioViewType)type
{
    switch (type) {
        case YOASVedioViewType1X1:
            _outputSize = CGSizeMake(ScreenWidth, ScreenWidth);
            break;
        case YOASVedioViewType4X3:
            _outputSize = CGSizeMake(ScreenWidth, ScreenWidth*4/3);
            break;
        case YOASVedioViewTypeFullScreen:
            _outputSize = CGSizeMake(ScreenWidth, ScreenHeight);
            break;
        default:
             _outputSize = CGSizeMake(ScreenWidth, ScreenHeight);
            break;
    }
    _writeQueue = dispatch_queue_create("com.5miles", DISPATCH_QUEUE_SERIAL);
    _recordTime = 0;
}

-(instancetype)initWithURL:(NSURL *)URL viewType:(YOASVedioViewType)type
{
    self = [super init];
    if (self) {
        
        _videoUrl = URL;
        _viewType = type;
        [self setUpInitWithType:type];
    }
    
    return self;
    
}

/**
 开始写入数据
 */
-(void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
    if (sampleBuffer == NULL) {
        NSLog(@"空缓冲区");
        return;
    }
    
    @synchronized (self) {
        if (self.writeState < YOASRecordStateRecording) {
            NSLog(@"还未准备好");
            return;
        }
    }
    
    CFRetain(sampleBuffer);
    dispatch_async(self.writeQueue, ^{
        
        @autoreleasepool {
            @synchronized (self) {
                
                if (self.writeState > YOASRecordStateRecording) {
                    CFRelease(sampleBuffer);
                    return ;
                }
            }
            
            
            if (!self.canWrite && mediaType == AVMediaTypeVideo) {
                
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            
            __weak __typeof(self)weakSelf = self;
            if (!weakSelf.timer) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                     weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
                });
            }
            
            //写入视频数据
            if (mediaType == AVMediaTypeVideo) {
                
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            
            //写入音频
            if (mediaType == AVMediaTypeAudio) {
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        [self stopWrite];
                        [self destroyWrite];
                    }
                }
                
            }
           
            CFRelease(sampleBuffer);
        }
    });
}

-(void)startWrite
{
    self.writeState = YOASRecordStatePrepareRecording;
    if (!self.assetWriter) {
        [self setUpWriter];
    }
    
}

-(void)stopWrite
{
    self.writeState = YOASRecordStateFinish;
    [self.timer invalidate];
    self.timer = nil;
    __weak typeof (self)weakSelf = self;
    if (_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting) {
        
        dispatch_async(self.writeQueue, ^{
            [weakSelf.assetWriter finishWritingWithCompletionHandler:^{
                ALAssetsLibrary *lib = [[ALAssetsLibrary alloc]init];
                [lib writeVideoAtPathToSavedPhotosAlbum:weakSelf.videoUrl completionBlock:nil];
            }];
        });
        
    }
  
}

-(void)updateProgress
{
    
    if (_recordTime >= 10.0) {
        [self stopWrite];
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishWriting)]) {
            [self.delegate finishWriting];
        }
        return;
    }
    
    _recordTime += 0.05;
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateWritingProgress:)]) {
        [self.delegate updateWritingProgress:_recordTime/10.0];
    }
    
}

-(void)setUpWriter
{
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoUrl fileType:AVFileTypeMPEG4 error:nil];
    //写入视频的大小
    NSInteger numPixels = self.outputSize.width * self.outputSize.height;
    //没像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSeond = numPixels * bitsPerPixel;
    
    //码率和帧率的设置
    NSDictionary *compressionProperties = @{
                                            
                                            AVVideoAverageBitRateKey:@(bitsPerSeond),
                                            AVVideoExpectedSourceFrameRateKey:@(30),
                                            AVVideoMaxKeyFrameIntervalKey:@(30),
                                        AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel
                                            
                                            
                                            };
    
    //视频属性
    self.videoCompressionSettings = @{
                                      
                                      AVVideoCodecKey:AVVideoCodecH264,
                                      AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                      AVVideoWidthKey:@(self.outputSize.height),
                                      AVVideoHeightKey:@(self.outputSize.width),
                                      AVVideoCompressionPropertiesKey:compressionProperties
                                    
                                      
                                      
                                      };
    
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    
    //音频设置
    self.audioCompressionSettings = @{
                                      
                                      AVEncoderBitRatePerChannelKey:@(28000),
                                      AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                      AVNumberOfChannelsKey:@(1),
                                      AVSampleRateKey:@(22050)

                                      };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;

    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        
        [_assetWriter addInput:_assetWriterVideoInput];
    }else{
        
        NSLog(@"拼接失败");
    }
    
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else{
          NSLog(@"拼接失败");
    }
    self.writeState = YOASRecordStateRecording;
}


-(BOOL)checkPathUrl:(NSURL *)url
{
    if (!url) {
        return NO;
    }
    
    if ([YOFileManager isExistsAtPath:[url path]]) {
        
        return [YOFileManager removeItemAtPath:[url path]];
    }
    
    return YES;

}

- (void)destroyWrite
{
    self.assetWriter = nil;
    self.assetWriterAudioInput = nil;
    self.assetWriterVideoInput = nil;
    self.videoUrl = nil;
    self.recordTime = 0;
    [self.timer invalidate];
    self.timer = nil;
    
}

- (void)dealloc
{
    [self destroyWrite];
}


@end
