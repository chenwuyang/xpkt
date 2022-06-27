//
//  VTMP4Encoder.h
//  AFNetworking
//
//  Created by Vincent on 2019/1/1.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface VTMP4Encoder : NSObject
///// 根据图片内容生成mp4文件
//+ (void)imageToMP4:(UIImage *)img completion:(void (^)(NSData *))handler;

/// 根据视图内容生成mp4文件
+ (void)viewToMP4:(NSView *)view completion:(void (^)(NSData *))handler;
@end
