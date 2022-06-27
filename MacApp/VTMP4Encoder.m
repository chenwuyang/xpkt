//
//  VTMP4Encoder.m
//  AFNetworking
//
//  Created by Vincent on 2019/1/1.
//

#import "VTMP4Encoder.h"
#import <AVFoundation/AVFoundation.h>


@implementation VTMP4Encoder


+ (NSImage *)convertViewToImage:(NSView *)view{
    //    焦点锁定
    [view lockFocus];
    //    生成所需图片
    NSImage *image = [[NSImage alloc]initWithData:[view dataWithPDFInsideRect:[view bounds]]];
    [view unlockFocus];
    return image;
}

///** 合成宽*16像素图片 */
//+ (UIImage *)composite_Picture:(UIImage *)image{
//    CGSize imageContSize = CGSizeMake(((int)image.size.width/16+1)*16, ((int)image.size.width/16+1)*16/(image.size.width/image.size.height));
//    //开启图形上下文
//    UIGraphicsBeginImageContext(imageContSize);
//
//    [image drawInRect:CGRectMake(0, 0, imageContSize.width, imageContSize.height)];
//    //获取图片
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    //关闭上下文
//    UIGraphicsEndImageContext();
//
//    NSLog(@"%f%f",newImage.size.width,newImage.size.height);
//
//    return newImage;
//}

/// 根据视图内容生成mp4文件
+ (void)viewToMP4:(NSView *)view completion:(void (^)(NSData *))handler{
    NSImage *img = [self convertViewToImage:view];
//    if (((int)img.size.width)%16 != 0) {
//        img = [self composite_Picture:img];
//    }
    NSLog(@"%f",img.size.width);
    NSError *error = nil;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"tmp"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    if ([fileMgr removeItemAtPath:videoOutputPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    CGSize imageSize = CGSizeMake(img.size.width, img.size.height);
    NSUInteger fps = 5;
    NSArray *imageArray = @[img];
    
    NSLog(@"videoOutputPath========%@", videoOutputPath);

    NSLog(@"Start building video from defined frames.");
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    /// !!!需要设置faststart
    videoWriter.shouldOptimizeForNetworkUse = YES;
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecTypeH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
        
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 1;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    //for(VideoFrame * frm in imageArray)
    NSLog(@"**************************************************");
    for(NSImage * img in imageArray)
    {
        //UIImage * img = frm._imageFrame;
        CGImageRef ref = [self nsImageToCGImageRef:img];
        buffer = [self pixelBufferFromCGImage:ref];
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                NSLog(@"Processing video frame (%d,%lu)",frameCount,(unsigned long)[imageArray count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    NSLog(@"**************************************************");
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        if (handler) {
            NSData *data = [NSData dataWithContentsOfFile:videoOutputPath];
            handler(data);
        }
    }];
    
    
}

//+ (void)imageToMP4:(UIImage *)img completion:(void (^)(NSData *))handler {
//    if (((int)img.size.width)%16 != 0) {
//        img = [self composite_Picture:img];
//    }
//
//    NSLog(@"%f",img.size.width);
//    NSError *error = nil;
//
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    NSString *documentsDirectory = [NSHomeDirectory()
//                                    stringByAppendingPathComponent:@"tmp"];
//    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
//    if ([fileMgr removeItemAtPath:videoOutputPath error:&error] != YES)
//        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
//
//    CGSize imageSize = CGSizeMake(img.size.width, img.size.height);
//    NSUInteger fps = 5;
//    NSArray *imageArray = @[img];
//
//    NSLog(@"videoOutputPath========%@", videoOutputPath);
//
//    NSLog(@"Start building video from defined frames.");
//
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
//                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeQuickTimeMovie
//                                                              error:&error];
//    /// !!!需要设置faststart
//    videoWriter.shouldOptimizeForNetworkUse = YES;
//    NSParameterAssert(videoWriter);
//
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecTypeH264, AVVideoCodecKey,
//                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
//                                   nil];
//
//    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
//                                            assetWriterInputWithMediaType:AVMediaTypeVideo
//                                            outputSettings:videoSettings];
//
//
//    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
//                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
//                                                     sourcePixelBufferAttributes:nil];
//
//    NSParameterAssert(videoWriterInput);
//    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
//    videoWriterInput.expectsMediaDataInRealTime = YES;
//    [videoWriter addInput:videoWriterInput];
//
//    //Start a session:
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//
//    CVPixelBufferRef buffer = NULL;
//
//    //convert uiimage to CGImage.
//    int frameCount = 0;
//    double numberOfSecondsPerFrame = 1;
//    double frameDuration = fps * numberOfSecondsPerFrame;
//
//    //for(VideoFrame * frm in imageArray)
//    NSLog(@"**************************************************");
//    for(UIImage * img in imageArray)
//    {
//        //UIImage * img = frm._imageFrame;
//        buffer = [self pixelBufferFromCGImage:[img CGImage]];
//
//        BOOL append_ok = NO;
//        int j = 0;
//        while (!append_ok && j < 30) {
//            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
//                //print out status:
//                NSLog(@"Processing video frame (%d,%lu)",frameCount,(unsigned long)[imageArray count]);
//
//                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
//                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
//                if(!append_ok){
//                    NSError *error = videoWriter.error;
//                    if(error!=nil) {
//                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
//                    }
//                }
//            }
//            else {
//                printf("adaptor not ready %d, %d\n", frameCount, j);
//                [NSThread sleepForTimeInterval:0.1];
//            }
//            j++;
//        }
//        if (!append_ok) {
//            printf("error appending image %d times %d\n, with error.", frameCount, j);
//        }
//        frameCount++;
//    }
//    NSLog(@"**************************************************");
//
//    //Finish the session:
//    [videoWriterInput markAsFinished];
//    [videoWriter finishWritingWithCompletionHandler:^{
//        if (handler) {
//            NSData *data = [NSData dataWithContentsOfFile:videoOutputPath];
//            handler(data);
//        }
//    }];
//
//
//}

+ (CGImageRef)nsImageToCGImageRef:(NSImage*)image;{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(imageData){
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return imageRef;
}

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image {
    
    CGSize size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end
