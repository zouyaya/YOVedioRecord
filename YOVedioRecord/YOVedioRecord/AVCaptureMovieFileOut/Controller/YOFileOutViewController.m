//
//  YOFileOutViewController.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/21.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOFileOutViewController.h"
#import "YOFileOutVedioView.h"
#import "YOVedioPlayerViewController.h"


@interface YOFileOutViewController ()<YOFileOutVedioViewDelegate>

@property (strong, nonatomic) YOFileOutVedioView *vedioView;

@end

@implementation YOFileOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiliazeViewUI];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(void)initiliazeViewUI
{
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _vedioView = [[YOFileOutVedioView alloc]initWithFMVideoViewType:TypeFullScreen];
    _vedioView.delegate = self;
    [self.view addSubview:_vedioView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_vedioView.fmodel.recordState == FMRecordStateFinish) {
        [_vedioView reset];
    }
    
}
#pragma mark - FMFVideoViewDelegate
- (void)dismissVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordFinishWithvideoUrl:(NSURL *)videoUrl
{
    YOVedioPlayerViewController *playVC = [[YOVedioPlayerViewController alloc] init];
    playVC.vedioUrl =  videoUrl;
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
