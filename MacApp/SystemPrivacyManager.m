//
//  SystemPrivacyManager.m
//  Mi
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 Mi. All rights reserved.
//

#import "SystemPrivacyManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
//#import <EventKit/EventKit.h>
//#import <AddressBook/AddressBook.h>
//#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
//#import <CoreBluetooth/CoreBluetooth.h>
//#import <HealthKit/HealthKit.h>
//#import <MediaPlayer/MediaPlayer.h>

@interface SystemPrivacyManager () <CLLocationManagerDelegate>//,CBCentralManagerDelegate>
@property(nonatomic, copy) SystemPrivacyHandler handler;
@property(nonatomic, strong) CLLocationManager *locationManager;
//@property(nonatomic, strong) CBCentralManager *centralManager;
//@property(nonatomic, strong) HKHealthStore *healthStore;
@property(nonatomic ,assign)SystemPrivacyType type;
@end

@implementation SystemPrivacyManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SystemPrivacyManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return [SystemPrivacyManager sharedInstance];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [SystemPrivacyManager sharedInstance];
}

- (void)systemPrivacyType:(SystemPrivacyType)type handler:(SystemPrivacyHandler)handler {
    self.type = type;
    self.handler = handler;
    
    switch (type) {
        case SystemPrivacyTypeMediaLibrary:             //多媒体
            [self getSystemPrivacyTypeMediaLibrary];
            break;
        case SystemPrivacyTypeMic:                      //麦克风权限
            [self getSystemPrivacyTypeMic];
            break;
        case SystemPrivacyTypeCamera:                   //相机权限
            [self getSystemPrivacyTypeCamera];
            break;
        case SystemPrivacyTypePhoto:                    //相册权限
            [self getSystemPrivacyTypePhoto];
            break;
        case SystemPrivacyTypeLocationWhen:             //获取地理位置When
//            [self getSystemPrivacyTypeLocationWhen];
            break;
        case SystemPrivacyTypeCalendar:                 //日历
            [self getSystemPrivacyTypeCalendar];
            break;
        case SystemPrivacyTypeContacts:                 //联系人
            [self getSystemPrivacyTypeContacts];
            break;
        case SystemPrivacyTypeBlue:                     //蓝牙
            [self getSystemPrivacyTypeBlue];
            break;
        case SystemPrivacyTypeRemaine:                  //提醒
            [self getSystemPrivacyTypeRemaine];
            break;
        case SystemPrivacyTypeHealth:                   //健康
            [self getSystemPrivacyTypeHealth];
            break;
        default:
            break;
    }
}


#pragma mark - 自定义方法
#pragma mark - 多媒体
- (void)getSystemPrivacyTypeMediaLibrary {
//    __block SystemPrivacyManager *weakSelf = self;
//    if (@available(iOS 9.3, *)) {
//        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
//            switch (status) {
//                case MPMediaLibraryAuthorizationStatusNotDetermined: {
//                    weakSelf.handler(NO, @(status));
//                    break;
//                }
//                case MPMediaLibraryAuthorizationStatusRestricted: {
//                    weakSelf.handler(NO, @(status));
//                    break;
//                }
//                case MPMediaLibraryAuthorizationStatusDenied: {
//                    weakSelf.handler(NO, @(status));
//                    break;
//                }
//                case MPMediaLibraryAuthorizationStatusAuthorized: {
//                        // authorized
//                    weakSelf.handler(YES, @(status));
//                    break;
//                }
//                default: {
//                    break;
//                }
//            }
//
//        }];
//    } else {
//        [self pushSetting:@"您的版本过低,不支持该功能!"];
//    }
}

#pragma mark - 麦克风
- (void)getSystemPrivacyTypeMic {
//    AVAudioSessionRecordPermission micPermisson = [[AVAudioSession sharedInstance] recordPermission];
//    __block SystemPrivacyManager *weakSelf = self;
//    if (micPermisson == AVAudioSessionRecordPermissionUndetermined) {
//        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//            weakSelf.handler(granted, @(micPermisson));
//        }];
//    } else if (micPermisson == AVAudioSessionRecordPermissionGranted) {
//        self.handler(YES, @(micPermisson));
//    } else {
//        self.handler(NO, @(micPermisson));
//        [self pushSetting:@"麦克风权限"];
//    }
}

#pragma mark - 相机
- (void)getSystemPrivacyTypeCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __block SystemPrivacyManager *weakSelf = self;
    if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            weakSelf.handler(granted, @(authStatus));
        }];
    }  else if (authStatus == AVAuthorizationStatusAuthorized) {
        self.handler(YES, @(authStatus));
    } else if(authStatus == AVAuthorizationStatusRestricted||authStatus == AVAuthorizationStatusDenied){
        self.handler(NO, @(authStatus));
        [self pushSetting:@"相机权限"];
    }else{
        self.handler(NO, @(authStatus));
    }
}

#pragma mark - 相册
- (void)getSystemPrivacyTypePhoto {
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    __block SystemPrivacyManager *weakSelf = self;
    if (photoStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                weakSelf.handler(YES, @(photoStatus));
            } else {
                weakSelf.handler(NO, @(photoStatus));
            }
        }];
    } else if (photoStatus == PHAuthorizationStatusAuthorized) {
        self.handler(YES, @(photoStatus));
    } else if(photoStatus == PHAuthorizationStatusRestricted||photoStatus == PHAuthorizationStatusDenied){
        self.handler(NO, @(photoStatus));
        [self pushSetting:@"相册权限"];
        
    } else{
        self.handler(NO, @(photoStatus));
    }
}

#pragma mark - 定位(打开应用时)
//- (void)getSystemPrivacyTypeLocationWhen {
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        if (!self.locationManager) {
//            self.locationManager = [[CLLocationManager alloc] init];
//            self.locationManager.delegate = self;
//        }
//        [self.locationManager requestWhenInUseAuthorization];
//    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
//        self.handler (YES, @(status));
//    } else {
//        self.handler(NO, @(status));
//        [self pushSetting:@"使用期间访问地理位置权限"];
//    }
//}

//定位权限改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

#pragma mark - 日历
- (void)getSystemPrivacyTypeCalendar {
//    EKEntityType type  = EKEntityTypeEvent;
//    __block SystemPrivacyManager *weakSelf = self;
//    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
//    if (status == EKAuthorizationStatusNotDetermined) {
//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
//            weakSelf.handler(granted,@(status));
//        }];
//    } else if (status == EKAuthorizationStatusAuthorized) {
//        self.handler(YES,@(status));
//    } else {
//        [self pushSetting:@"日历权限"];
//        self.handler(NO,@(status));
//    }
}

#pragma mark - 联系人
- (void)getSystemPrivacyTypeContacts {
//    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//    __block SystemPrivacyManager *weakSelf = self;
//    if (status == CNAuthorizationStatusNotDetermined) {
//        CNContactStore *store = [[CNContactStore alloc] init];
//        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//            if (granted) {
//                weakSelf.handler(granted,[weakSelf openContact]);
//            }
//            weakSelf.handler(granted,@(status));
//        }];
//    } else if (status == CNAuthorizationStatusAuthorized) {;
//        self.handler(YES,[self openContact]);
//    } else {
//        self.handler(NO,@(status));
//        [self pushSetting:@"联系人权限"];
//    }
}


#pragma mark - 蓝牙
- (void)getSystemPrivacyTypeBlue {
//    if (!self.centralManager) {
//        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
//    }
}

#pragma mark - 提醒
- (void)getSystemPrivacyTypeRemaine {
//    EKEntityType type  = EKEntityTypeReminder;
//    __block SystemPrivacyManager *weakSelf = self;
//    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
//    if (status == EKAuthorizationStatusNotDetermined) {
//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
//            weakSelf.handler(granted,@(status));
//        }];
//    } else if (status == EKAuthorizationStatusAuthorized) {
//        self.handler(YES,@(status));
//    } else {
//        [self pushSetting:@"日历权限"];
//        self.handler(NO,@(status));
//    }
}

#pragma mark - 健康
- (void)getSystemPrivacyTypeHealth {
//    if (![HKHealthStore isHealthDataAvailable]) {
//        NSLog(@"设备不支持healthKit");
//        self.handler(NO, nil);
//        return;
//    }
//
//    if (!self.healthStore) {
//        self.healthStore = [HKHealthStore new];
//    }
//
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    __block SystemPrivacyManager *weakSelf = self;
//    NSSet *readDataTypes =  [NSSet setWithObjects:stepType, nil];
//    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
//        if (success) {
//            [weakSelf readStepCount];
//        }else{
//            weakSelf.handler(NO, nil);
//        }
//    }];
}

#pragma mark - 系统代理
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    self.handler(YES, error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    self.handler(YES, locations.firstObject);
//    [self.locationManager stopUpdatingLocation];
//    self.locationManager.delegate = nil;
//    self.locationManager = nil;
}

#pragma mark - CBCentralManagerDelegate
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    if (central.state == CBCentralManagerStatePoweredOn) {
//        self.handler(YES, nil);
//    } else {
//        self.handler(NO, nil);
//    }
//}

#pragma mark - 过去通讯录信息
- (NSArray*)openContact {
        // 获取指定的字段
//    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
//    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
//    CNContactStore *contactStore = [[CNContactStore alloc] init];
//    NSMutableArray *arr = [NSMutableArray new];
//    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
//            //拼接姓名
//        NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
//
//        NSArray *phoneNumbers = contact.phoneNumbers;
//
//        for (CNLabeledValue *labelValue in phoneNumbers) {
//            CNPhoneNumber *phoneNumber = labelValue.value;
//            NSString * string = phoneNumber.stringValue ;
//                //去掉电话中的特殊字符
//            string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
//            string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
//            string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
//            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
//            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
//            NSLog(@"姓名=%@, 电话号码是=%@", nameStr, string);
//            [arr addObject:@{@"name":nameStr,@"phone":string}];
//        }
//    }];
//    return [NSArray arrayWithArray:arr];
    return @[];
}

/*
 * 查询步数数据
 */
- (void)readStepCount {
//    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
//
//    __block SystemPrivacyManager *weakSelf = self;
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[SystemPrivacyManager predicateForSamplesToday]
//                                                               limit:HKObjectQueryNoLimit
//                                                     sortDescriptors:@[timeSortDescriptor]
//                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
//        if (error) {
//            weakSelf.handler(NO, error);
//        } else {
//            NSInteger totleSteps = 0;
//            for(HKQuantitySample *quantitySample in results) {
//                HKQuantity *quantity = quantitySample.quantity;
//                HKUnit *heightUnit = [HKUnit countUnit];
//                double usersHeight = [quantity doubleValueForUnit:heightUnit];
//                totleSteps += usersHeight;
//            }
//            NSLog(@"当天行走步数 = %ld",(long)totleSteps);
//            weakSelf.handler(YES,@(totleSteps));
//        }
//    }];
//
//    [self.healthStore executeQuery:query];
}

/*
 *跳转设置
 */
- (void)pushSetting:(NSString*)urlStr {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
//                                                                   message:[NSString stringWithFormat:@"%@%@",urlStr,self.tips]
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
////    kWeakSelf(self);
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
////        if (weakSelf.type==SystemPrivacyTypeLocationWhen) {
////            CityListController *vc = [[CityListController alloc] init];
////            [[SystemPrivacyManager getCurrentVC].navigationController pushViewController:vc animated:YES];
////        }
//    }];
//    [alert addAction:cancelAction];
//
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSURL *url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//
//        if (@available(iOS 10, *)) {
//            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
//                [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL success) {
//                }];
//            }
//        } else {
//            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
//                [[UIApplication sharedApplication]openURL:url];
//            }
//        }
//    }];
//    [alert addAction:okAction];
//    [[SystemPrivacyManager getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

//+ (UIViewController *)getCurrentVC {
//    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
//
//    return currentVC;
//}

//+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
//    UIViewController *currentVC;
//
//    if ([rootVC presentedViewController]) {
//            // 视图是被presented出来的
//        rootVC = [rootVC presentedViewController];
//    }
//
//    if ([rootVC isKindOfClass:[UITabBarController class]]) {
//            // 根视图为UITabBarController
//        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
//
//    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
//            // 根视图为UINavigationController
//        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
//
//    } else {
//            // 根视图为非导航类
//        currentVC = rootVC;
//    }
//    return currentVC;
//}

- (NSString *)tips {
    if (!_tips) {
        _tips = @"尚未开启,是否前往设置";
    }
    return _tips;
}

/*!
 *  @brief  当天时间段(可以获取某一段时间)
 *
 *  @return 时间段
 */
//+ (NSPredicate *)predicateForSamplesToday {
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDate *now = [NSDate date];
//    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
//    [components setHour:0];
//    [components setMinute:0];
//    [components setSecond: 0];
//    
//    NSDate *startDate = [calendar dateFromComponents:components];
//    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
//    return predicate;
//}

@end
