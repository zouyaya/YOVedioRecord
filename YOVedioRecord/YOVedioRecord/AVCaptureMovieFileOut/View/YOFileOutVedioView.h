//
//  YOFileOutVedioView.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/21.
//  Copyright © 2019 hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YOFileOutVedioModel.h"

NS_ASSUME_NONNULL_BEGIN


@protocol YOFileOutVedioViewDelegate <NSObject>

-(void)dismissVC;
-(void)recordFinishWithvideoUrl:(NSURL *)videoUrl;

@end

@interface YOFileOutVedioView : UIView

@property (nonatomic, assign) FMVideoViewType viewType;
@property (nonatomic, strong, readonly) YOFileOutVedioModel *fmodel;
@property (nonatomic, weak) id <YOFileOutVedioViewDelegate> delegate;

- (instancetype)initWithFMVideoViewType:(FMVideoViewType)type;
- (void)reset;



@end

NS_ASSUME_NONNULL_END
