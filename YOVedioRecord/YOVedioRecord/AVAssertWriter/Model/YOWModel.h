//
//  YOWModel.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVAssertWriterManager.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger,YOFlashState)
{
    YOFlashStateClose,
    YOFlashStateOpen,
    YOFlashStateAuto,
    
};

@protocol YOWModelDelegate <NSObject>

- (void)updateFlashState:(YOFlashState)state;
- (void)updateRecordingProgress:(CGFloat)progress;
- (void)updateRecordState:(YOASRecordState)recordState;


@end

@interface YOWModel : NSObject


@property (nonatomic, weak  ) id<YOWModelDelegate>delegate;
@property (nonatomic, assign) YOASRecordState recordState;
@property (nonatomic, strong, readonly) NSURL *vedeoUrl;
- (instancetype)initWithFMVideoViewType:(YOASVedioViewType )type superView:(UIView *)superView;

- (void)turnCameraAction;
- (void)switchflash;
- (void)startRecord;
- (void)stopRecord;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
