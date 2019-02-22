//
//  AVAssertWriterManager.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,YOASRecordState)
{
    
    YOASRecordStateInit = 0,
    YOASRecordStatePrepareRecording,
    YOASRecordStateRecording,
    YOASRecordStateFinish,
    YOASRecordStateFail,

    
};

typedef NS_ENUM(NSInteger,YOASVedioViewType)
{
    YOASVedioViewType1X1,
    YOASVedioViewType4X3,
    YOASVedioViewTypeFullScreen,
    
};

@protocol AVAssertWriterManagerDelegate <NSObject>

- (void)finishWriting;
- (void)updateWritingProgress:(CGFloat)progress;

@end


@interface AVAssertWriterManager : NSObject

@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, assign) YOASRecordState writeState;
@property (nonatomic, weak) id <AVAssertWriterManagerDelegate> delegate;
- (instancetype)initWithURL:(NSURL *)URL viewType:(YOASVedioViewType )type;

- (void)startWrite;
- (void)stopWrite;
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType;
- (void)destroyWrite;

@end

NS_ASSUME_NONNULL_END
