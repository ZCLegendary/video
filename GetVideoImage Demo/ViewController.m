//
//  ViewController.m
//  GetVideoImage Demo
//
//  Created by myMac on 16/9/7.
//  Copyright © 2016年 myMac. All rights reserved.
//

#import "ViewController.h"
#import "SDAutoLayout.h"
#import "MobileCoreServices/UTCoreTypes.h"
#import "MethodClass.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) UIImagePickerController *pickerImage;
@property (nonatomic, strong) UIImage *savedImage;

@property (nonatomic, strong) UIImageView *imgPhotoVideo;

@property (nonatomic, strong) AVPlayerLayer *layer;

@property (nonatomic, copy) NSString *fullPath;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"视频拍摄及播放";
    
    //    [MethodClass removeCompressedVideoFromDocuments];
    
    self.imgPhotoVideo = [[UIImageView alloc] init];
    self.imgPhotoVideo.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.imgPhotoVideo];
    self.imgPhotoVideo.sd_layout.topSpaceToView(self.view, 180).leftSpaceToView(self.view, 100).rightSpaceToView(self.view, 100).heightIs(220);
    [self.imgPhotoVideo setImage:[UIImage imageNamed:@"p.png"]];
    
}


- (IBAction)play:(UIButton *)sender {
    
    NSLog(@"播放");
    
    //判断路径是否存在
    if (self.fullPath.length > 0) {
        
        self.playBtn.alpha = 0;
        NSURL *url = [NSURL fileURLWithPath:self.fullPath];
        NSLog(@"______%@", self.fullPath);
        
        
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
        _layer = [AVPlayerLayer playerLayerWithPlayer:player];
        _layer.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 330);
        _layer.backgroundColor = [UIColor cyanColor].CGColor;
        _layer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.view.layer addSublayer:_layer];
        [player play];
        
        //视频播放完成
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
        
    } else {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示信息"
                                                                            message:@"请先录制视频" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"是滴" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}

/**
 *
 *  通知方法
 *
 */

-  (void)playerItemDidReachEnd
{
    [_layer removeFromSuperlayer];
    self.playBtn.alpha = 1;
}


/**
 *
 *  录制方法
 *
 */

- (IBAction)changeImg:(UIButton *)sender {
    
    NSLog(@"开始录制");
    [self beginRecord];
}

- (void)beginRecord
{
    self.pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        self.pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.pickerImage.videoQuality = UIImagePickerControllerQualityTypeMedium;
#warning kUTTypeMovie 方法需要导入 #import "MobileCoreServices/UTCoreTypes.h"
        self.pickerImage.mediaTypes = @[(NSString *)kUTTypeMovie];
        self.pickerImage.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        //        self.pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //跳转相册界面
        [self presentViewController:self.pickerImage animated:YES completion:^{}];
        
    } else {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示信息" message:@"设备不支持视频录制" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
    self.pickerImage.delegate = self;
    self.pickerImage.allowsEditing = YES; // 设置选择的图片是否可编辑
    
    
}

/**
 *
 *  代理方法
 *
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 返回上一个视图
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    //获取沙盒目录
    //self.fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [MethodClass getCurrentDateTime]]];
    
    //将视频压缩过程放入子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
        self.fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/CompressionVideoField"] stringByAppendingPathComponent:@"outputJFVideo.mov"];
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        //视频数据写入
        NSData *data = [NSData dataWithContentsOfURL:videoURL];
        [data writeToFile:self.fullPath atomically:NO];
        
        
        self.playBtn.userInteractionEnabled = NO;

        
        [MethodClass compressedVideoOtherMethodWithURL:videoURL compressionType:AVAssetExportPresetLowQuality compressionResultPath:^(NSString *result, float progressTime, float size) {
            
            NSLog(@"%@, %f", result, size);
            
            if (progressTime == floorf(1)) {
                NSLog(@"视频压缩完成");
                //开启 playBtn 交互
                self.playBtn.userInteractionEnabled = YES;
            }
            
        }];
        
        //网络请求之后进入主线程
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSLog(@"回到主程");
            // 显示缩略图
            
            self.savedImage = [MethodClass thumbnailImageForVideo:videoURL atTime:3];
            self.imgPhotoVideo.contentMode = UIViewContentModeScaleAspectFit;
            self.imgPhotoVideo.backgroundColor = [UIColor blackColor];
            [self.imgPhotoVideo setImage:self.savedImage];

        });
    });
}

 /**
 *
 *  代理方法
 *
 */

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
