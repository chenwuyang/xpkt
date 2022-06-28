//
//  VTSimplePlayer.h
//  VTAntiScreenCapture_Example
//
//  Created by Vincent on 2018/12/31.
//  Copyright © 2018 mightyme@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface VTSimplePlayer : NSObject

- (void)playURL:(NSString *)url inView:(NSView *)container;

@end
