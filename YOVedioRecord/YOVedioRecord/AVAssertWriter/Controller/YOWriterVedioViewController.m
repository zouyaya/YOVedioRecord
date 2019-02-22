//
//  YOWriterVedioViewController.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/22.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOWriterVedioViewController.h"
#import "YOAVASSetWriterView.h"
#import "YOVedioPlayerViewController.h"

@interface YOWriterVedioViewController ()<YOAVASSetWriterViewDelegate>

@property (strong, nonatomic) YOAVASSetWriterView *vedioView;

@end

@implementation YOWriterVedioViewController


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    _vedioView  =[[YOAVASSetWriterView alloc] initWithFMVideoViewType:YOASVedioViewType1X1];
    _vedioView.delegate = self;
    [self.view addSubview:_vedioView];
    self.view.backgroundColor = [UIColor blackColor];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_vedioView.fmodel.recordState == YOASRecordStateFinish) {
        [_vedioView.fmodel reset];
    }
}


-(void)disMissVC
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)recordFinishWithVedioUrl:(NSURL *)vedioUrl
{
    YOVedioPlayerViewController *playVC = [[YOVedioPlayerViewController alloc] init];
    playVC.vedioUrl =  vedioUrl;
    [self.navigationController pushViewController:playVC animated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
