//
//  MethodClass.h
//  GetVideoImage Demo
//
//  Created by myMac on 16/9/7.
//  Copyright © 2016年 myMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CompressionSuccessBlock)(NSString *result, float progressTime, float size);

@interface MethodClass : NSObject


/**
 *
 * 获取当前时间
 *
 */

+ (NSString *)getCurrentDateTime;

/**
 * @brief 获取视频的某一帧的图片
 * @param videoURL:视频的url
 * @param atTime:某一帧的时间
 * @return 图片
 */
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time;

/**
 *
 *  视频压缩
 *  @param URL: 视频播放 url
 *  @param compressionType: 视频压缩类型
 *  @param compressionResultPath: 结果回调
 */

+ (void)compressedVideoOtherMethodWithURL:(NSURL *)url
                          compressionType:(NSString *)compressionType
                    compressionResultPath:(CompressionSuccessBlock)resultPathBlock;


/**
 *
 * 清除文件夹
 *
 */

+ (void)removeCompressedVideoFromDocuments;

@end
