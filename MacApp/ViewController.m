//
//  ViewController.m
//  Mac App
//
//  Created by lanshan on 2022/4/6.
//

#import "ViewController.h"
#import <sys/sysctl.h>
#import <libproc.h>
#import "VTSimplePlayer.h"
#import "GCDWebServer.h"
#import "VTMP4Encoder.h"
#import "NoticeView.h"
#import "NoticeView.h"


@interface ViewController()<GCDWebServerDelegate>
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSMutableArray *blackListProcessArray;//黑名单进程名
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, strong) VTSimplePlayer *player;
@property (nonatomic,strong)NoticeView *noticeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
            
//    self.webView.customUserAgent = @"safari";
//    [self clearWebCache];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
//    self.blackListProcessArray = [NSArray arrayWithObject:@"screencapture"];
//    [self getBlackList];

    [self setupTimer];
    
    [self getWebUrl];
    
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * result, NSError * _Nullable error) {
        NSString *userAgent = result;
        NSMutableString *muStr = [[NSMutableString alloc] initWithFormat:@"%@lanshan-education",userAgent];
        NSLog(@"=====%@========",muStr);
        weakSelf.webView.customUserAgent = muStr;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWindowSize) name:NSWindowDidEndLiveResizeNotification object:nil];
    
}

- (void)changeWindowSize{
    self.noticeView.frame = self.view.frame;
    self.noticeView.bgView.frame = CGRectMake((self.view.bounds.size.width-377)/2, (self.view.bounds.size.height-130)/2, 377, 130);
}



- (void)viewDidAppear{
    NSWindow *window = [self.view window];
    window.sharingType = NSWindowSharingNone;
}


//禁止截屏
- (void)banshot{
    
    _webServer = [[GCDWebServer alloc] init];
    _webServer.delegate = self;
    NSError *error;
    NSString *dir=[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/www/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];

    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"tmp"];
    NSString *path = [[[NSURL fileURLWithPath:documentsDirectory] path] stringByAppendingPathComponent:@"test_output.mp4"];
    NSString *toPath = [[[NSURL fileURLWithPath:dir] path] stringByAppendingPathComponent:@"text"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
    }
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:nil];
    if (success) {
        NSLog(@"成功了");
    }else{
        NSLog(@"失败了");
    }

    [_webServer addGETHandlerForBasePath:@"/" directoryPath:dir indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    [_webServer startWithPort:8080 bonjourName:nil];

    _player = [VTSimplePlayer new];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.player playURL:@"jedi://text.m3u8" inView:weakSelf.view];
    });
}





//清除WKWebView缓存
- (void)clearWebCache{
    if(@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"清除缓存完毕");
        }];
    }else{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    }
}




- (void)getWebUrl{
    NSString *urlStr = @"http://test.fhzjedu.com/fhzjPcService/commonData/getPcConfig";
    //1.获取session
   NSURLSession *session = [NSURLSession sharedSession];
    //2.设置url
   NSURL *url =
   [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    //3.创建可变的request
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.添加参数
   NSString *param = [NSString stringWithFormat:@"type=%@", @"2"];
   request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    //5.设置请求方式为POST
   request.HTTPMethod = @"POST";
    //6.设置请求头(可选, 在必要时添加)
//   [request setValue: value forHTTPHeaderField: key];
    //7.创建task 并设置请求回调的block
   NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       if (error) {
           NSLog(@"%@", [error localizedDescription]);
       }
       if (data) {
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *result = dict[@"result"];
           NSLog(@"======%@======",result);
           NSArray *blackList = result[@"blackList"];
           self.blackListProcessArray = [NSMutableArray arrayWithArray:blackList];
           NSString *urlString = [NSString stringWithFormat:@"http://test.fhzjedu.com/xuepeipcclient/?ver=%@",result[@"versionNo"]?result[@"versionNo"]:@"123456"];
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
           });
       }
   }];
    //8.开始请求
   [dataTask resume];
}

- (void)setupTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timeAction{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self runningProcesses]];
    [self enumArrayWithProcessArray:array];
}

- (void)enumArrayWithProcessArray:(NSArray *)processArray{
    for (NSDictionary *dic in processArray) {
        NSString *processName = dic[@"ProcessName"];
        for (NSDictionary *blackDic in self.blackListProcessArray) {
            if ([blackDic[@"matchingType"] integerValue]==1) {
                if ([processName containsString:blackDic[@"processName"]]) {
                    [self addBlackView];
                }
            }else{
                if ([processName isEqualToString:blackDic[@"processName"]]) {
                    [self addBlackView];
                }
            }
        }
    }
}

- (void)alertAction{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"提示";
    alert.informativeText = @"检测到您的设备开启了录屏应用，程序将在5秒后自动关闭";//内容
    [alert addButtonWithTitle:@"确定"];//按钮所显示的文案
    [alert runModal];
}

//监测到录屏软件添加遮罩图层
- (void)addBlackView{
    [self.view addSubview:self.noticeView];
    [self.noticeView setBlock:^{
        [self.noticeView removeFromSuperview];
    }];
}


- (NoticeView *)noticeView{
    if (!_noticeView) {
        _noticeView = [[NoticeView alloc] initWithFrame:self.view.frame];
    }
    return _noticeView;;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


//获取系统进程数组
- (NSArray *)runningProcesses {
    
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    u_int miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = (int)(size / sizeof(struct kinfo_proc));
            
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    pid_t pid = process[i].kp_proc.p_pid;
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", pid];
                    NSString * processName = [self getProcessNameWithPid:pid];
                    if (processName.length > 0 && processID.length > 0) {
                        NSDictionary * dict = @{@"ProcessName" : processName, @"ProcessID" : processID };
                        [array addObject:dict];
                    }
                }
                
                free(process);
                return [array copy];
            }
        }
    }
    
    return nil;
}

- (NSString *)getProcessNameWithPid:(pid_t)pid
{
    NSString *processName = @"";
    char pathBuffer [PROC_PIDPATHINFO_MAXSIZE];
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    
    char nameBuffer[256];
    
    int position = (int)strlen(pathBuffer);
    while(position >= 0 && pathBuffer[position] != '/')
    {
        position--;
    }
    
    strcpy(nameBuffer, pathBuffer + position + 1);
    
    processName = [NSString stringWithUTF8String:nameBuffer];
    return processName;
}



@end
