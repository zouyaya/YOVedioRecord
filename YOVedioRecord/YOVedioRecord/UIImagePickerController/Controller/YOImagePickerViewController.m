//
//  YOImagePickerViewController.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/21.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOImagePickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface YOImagePickerViewController ()<UIActionSheetDelegate,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation YOImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = XTColorWithFloat(0xffffff);
    self.navigationItem.title = @"原生录制";
    [self initializeView];
}

-(void)initializeView
{
    UIButton *takeVedioBtn = [[UIButton alloc]init];
    takeVedioBtn.backgroundColor = XTColorWithFloat(0xff0000);
    takeVedioBtn.frame = CGRectMake((ScreenWidth - 100)/2, (ScreenHeight - 100)/2, 100, 100);
    takeVedioBtn.layer.cornerRadius = 50;
    takeVedioBtn.clipsToBounds = YES;
    [takeVedioBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    [takeVedioBtn setTitleColor:XTColorWithFloat(0xffffff) forState:UIControlStateNormal];
    [takeVedioBtn addTarget:self action:@selector(pressToTakeVedio:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeVedioBtn];
    
}


//打开相机
-(void)openCamera
{
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        NSLog(@"没有摄像头");
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
    
    
}
//相册中选择
-(void)openPhotoAlbum
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
    ipc.allowsEditing = YES;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //录制完的视频保存到相册
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:recordedVideoURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:recordedVideoURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){}
         ];
    }
    //拿到相关的视频doSomething
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark ----------@selector
-(void)pressToTakeVedio:(UIButton *)button
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *loginout = [UIAlertAction actionWithTitle:@"拍摄视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
         [self openCamera];
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openPhotoAlbum];
    }];
  
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alert addAction:loginout];
    [alert addAction:okAction];
    [alert addAction:cancleAction];
   [self presentViewController:alert animated:YES completion:nil];
  
   
    
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
