//
//  AppDelegate.m
//  Mac App
//
//  Created by lanshan on 2022/4/6.
//

#import "AppDelegate.h"
#import <AVKit/AVKit.h>
@import GitHubUpdates;


@interface AppDelegate ()
@property (nonatomic,strong)GitHubUpdater *updater;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    
    [self checkUpdater];
}

- (void)checkUpdater{
    self.updater = [GitHubUpdater new];
    self.updater.user = @"chenwuyang";
    self.updater.repository = @"https://github.com/chenwuyang/xpkt.git";
    [self.updater checkForUpdates:nil];
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
