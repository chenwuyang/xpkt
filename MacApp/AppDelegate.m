//
//  AppDelegate.m
//  Mac App
//
//  Created by lanshan on 2022/4/6.
//

#import "AppDelegate.h"
#import <AVKit/AVKit.h>


@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {

}



- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if (!flag){
        [[theApplication windows][0] makeKeyAndOrderFront:self];

    }
    return YES;
}


@end
