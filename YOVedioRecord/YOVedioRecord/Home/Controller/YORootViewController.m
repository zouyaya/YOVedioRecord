//
//  YORootViewController.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/15.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YORootViewController.h"
#import "YOHomeTableViewCell.h"
#import "YOImagePickerViewController.h"
#import "YOFileOutViewController.h"
#import "YOWriterVedioViewController.h"

@interface YORootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation YORootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"视频录制方式";
    
    [self initializeView];
    
}


/**
 初始化页面
 */
-(void)initializeView
{
    [self.view addSubview:self.tableView];
}


#pragma mark --------------UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    YOHomeTableViewCell *cell = [YOHomeTableViewCell cellWithTableView:tableView];
    [cell initCellDataAccordingToTHeIndexPath:indexPath];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            YOImagePickerViewController *imagePickerVC = [[YOImagePickerViewController alloc]init];
            [self.navigationController pushViewController:imagePickerVC animated:YES];
            
        }
            break;
        case 1:
        {
            YOFileOutViewController *fileOutVC = [[YOFileOutViewController alloc]init];
            [self presentViewController:fileOutVC animated:YES completion:nil];
        
            
        }
            break;
        case 2:
        {
            YOWriterVedioViewController *fileOutVC = [[YOWriterVedioViewController alloc]init];
            [self presentViewController:fileOutVC animated:YES completion:nil];
            
            
        }
            break;
            
        default:
            break;
    }
    
    
    
}


#pragma mark ------------懒加载
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    
    return _tableView;
    
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
