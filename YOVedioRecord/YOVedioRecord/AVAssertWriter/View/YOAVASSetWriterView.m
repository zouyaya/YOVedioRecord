//
//  YOAVASSetWriterView.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOAVASSetWriterView.h"
#import "YORecordProgressView.h"

@interface YOAVASSetWriterView ()<YOWModelDelegate>

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *cancleButton;
@property (strong, nonatomic) UIView *timeView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *turnCamera;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) YORecordProgressView *progressView;
@property (strong, nonatomic) UIButton *recordButton;
@property (assign, nonatomic) CGFloat recordTime;

@property (strong, nonatomic,readwrite) YOWModel *fmodel;


@end

@implementation YOAVASSetWriterView
-(instancetype)initWithFMVideoViewType:(YOASVedioViewType)type
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initializeViewWithType:type];
    }
    
    return self;
    
}


-(void)initializeViewWithType:(YOASVedioViewType)type
{
    self.fmodel = [[YOWModel alloc] initWithFMVideoViewType:type superView:self];
    self.fmodel.delegate = self;
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = XTColorWithFloat(0x000000);
    self.topView.frame = CGRectMake(0, 0, ScreenHeight, 44);
    [self addSubview:self.topView];
    
    self.timeView = [[UIView alloc] init];
    self.timeView.hidden = YES;
    self.timeView.frame = CGRectMake((ScreenWidth - 100)/2, 16, 100, 34);
    self.timeView.backgroundColor = XTColorWithFloat(0x242424);
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    [self addSubview:self.timeView];
    
    
    UIView *redPoint = [[UIView alloc] init];
    redPoint.frame = CGRectMake(0, 0, 6, 6);
    redPoint.layer.cornerRadius = 3;
    redPoint.layer.masksToBounds = YES;
    redPoint.center = CGPointMake(25, 17);
    redPoint.backgroundColor = [UIColor redColor];
    [self.timeView addSubview:redPoint];
    
    self.timeLabel =[[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:13];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.frame = CGRectMake(40, 8, 40, 28);
    [self.timeView addSubview:self.timeLabel];
    
    
    self.cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancleButton.frame = CGRectMake(15, 14, 16, 16);
    [self.cancleButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancleButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancleButton];
    
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCamera.frame = CGRectMake(ScreenWidth - 60 - 28, 11, 28, 22);
    [self.turnCamera setImage:[UIImage imageNamed:@"listing_camera_lens"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.turnCamera sizeToFit];
    [self.topView addSubview:self.turnCamera];
    
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(ScreenWidth - 22 - 15, 11, 22, 22);
    [self.flashButton setImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    [self.flashButton sizeToFit];
    [self.topView addSubview:self.flashButton];
    
    
    self.progressView = [[YORecordProgressView alloc] initWithFrame:CGRectMake((ScreenWidth - 62)/2, ScreenHeight - 32 - 62, 62, 62)];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressView];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    self.recordButton.frame = CGRectMake(5, 5, 52, 52);
    self.recordButton.backgroundColor = [UIColor redColor];
    self.recordButton.layer.cornerRadius = 26;
    self.recordButton.layer.masksToBounds = YES;
    [self.progressView addSubview:self.recordButton];
    [self.progressView resetProgress];
    
}

- (void)updateViewWithRecording
{
    self.timeView.hidden = NO;
    self.topView.hidden = YES;
    [self changeToRecordStyle];
}

- (void)updateViewWithStop
{
    self.timeView.hidden = YES;
    self.topView.hidden = NO;
    [self changeToStopStyle];
}

- (void)changeToRecordStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordButton.center;
        CGRect rect = self.recordButton.frame;
        rect.size = CGSizeMake(28, 28);
        self.recordButton.frame = rect;
        self.recordButton.layer.cornerRadius = 4;
        self.recordButton.center = center;
    }];
}
- (void)changeToStopStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordButton.center;
        CGRect rect = self.recordButton.frame;
        rect.size = CGSizeMake(52, 52);
        self.recordButton.frame = rect;
        self.recordButton.layer.cornerRadius = 26;
        self.recordButton.center = center;
    }];
}

-(void)dismissVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(disMissVC)]) {
        
        [self.delegate disMissVC];
    }
    
    
}

-(void)turnCameraAction
{
    [self.fmodel turnCameraAction];
    
}

-(void)flashAction
{
    [self.fmodel switchflash];
    
}

-(void)startRecord
{
    if (self.fmodel.recordState == YOASRecordStateInit) {
        [self.fmodel startRecord];
    } else if (self.fmodel.recordState == YOASRecordStateRecording) {
        [self.fmodel stopRecord];
    } else {
        [self.fmodel reset];
    }

    
}

- (void)stopRecord
{
    [self.fmodel stopRecord];
}

- (void)reset
{
    [self.fmodel reset];
}

#pragma mark - FMFModelDelegate

- (void)updateFlashState:(YOFlashState)state
{
    if (state == YOFlashStateOpen) {
        [self.flashButton setImage:[UIImage imageNamed:@"listing_flash_on"] forState:UIControlStateNormal];
    }
    if (state == YOFlashStateClose) {
        [self.flashButton setImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    }
    if (state == YOFlashStateAuto) {
        [self.flashButton setImage:[UIImage imageNamed:@"listing_flash_auto"] forState:UIControlStateNormal];
    }
}


- (void)updateRecordState:(YOASRecordState)recordState
{
    if (recordState == YOASRecordStateInit) {
        [self updateViewWithStop];
        [self.progressView resetProgress];
    } else if (recordState == YOASRecordStateRecording) {
        [self updateViewWithRecording];
    } else  if (recordState == YOASRecordStateFinish) {
        [self updateViewWithStop];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithVedioUrl:)]) {
            [self.delegate recordFinishWithVedioUrl:self.fmodel.vedeoUrl];
        }
    }
}

- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
    self.timeLabel.text = [self changeToVideotime:progress * 10.0];
    [self.timeLabel sizeToFit];
}

- (NSString *)changeToVideotime:(CGFloat)videocurrent {
    
    return [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
