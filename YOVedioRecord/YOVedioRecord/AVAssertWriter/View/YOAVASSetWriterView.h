//
//  YOAVASSetWriterView.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YOWModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YOAVASSetWriterViewDelegate <NSObject>

-(void)disMissVC;
-(void)recordFinishWithVedioUrl:(NSURL *)vedioUrl;

@end

@interface YOAVASSetWriterView : UIView

@property (nonatomic, assign) YOASVedioViewType viewType;
@property (nonatomic, strong, readonly) YOWModel *fmodel;
@property (nonatomic, weak) id <YOAVASSetWriterViewDelegate> delegate;

- (instancetype)initWithFMVideoViewType:(YOASVedioViewType)type;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
