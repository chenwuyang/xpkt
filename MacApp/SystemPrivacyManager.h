//
//  SystemPrivacyManager.h
//  Mi
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 Mi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SystemPrivacyType) {
    SystemPrivacyTypeCamera             = 0,      //相机权限
    SystemPrivacyTypeMic                = 1,      //麦克风权限
    SystemPrivacyTypePhoto              = 2,      //相册权限
    SystemPrivacyTypeLocationWhen       = 3,      //获取地理位置When
    SystemPrivacyTypeCalendar           = 4,      //日历
    SystemPrivacyTypeContacts           = 5,      //联系人
    SystemPrivacyTypeBlue               = 6,      //蓝牙
    SystemPrivacyTypeRemaine            = 7,      //提醒
    SystemPrivacyTypeHealth             = 8,      //健康
    SystemPrivacyTypeMediaLibrary       = 9       //多媒体
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^SystemPrivacyHandler) (BOOL granted, id data);

@interface SystemPrivacyManager : NSObject

/*
 * 提示
 */
@property(nonatomic,strong)NSString *tips;

/*
 * 单例
 */
+ (instancetype)sharedInstance;

/*
 * 获取权限
 * @param  type       类型
 * @param  block      回调
 */
- (void)systemPrivacyType:(SystemPrivacyType)type handler:(SystemPrivacyHandler)handler;

//是否游客登录
@property (nonatomic,strong)NSNumber *isVisitorLogin;//==1审核期间 ==2过审后

@property (nonatomic,strong)NSNumber *integralRatio;//学币积分比例
@property (nonatomic,strong)NSString *phoneNumber;//咨询电话
@property (nonatomic,strong)NSNumber *openDistribution;//是否开放分销1是 0否
@property (nonatomic,assign)NSInteger currentDistributionLevel;//当前分销层数
@property (nonatomic,assign)NSInteger maxDistributionLevel;//最大可查看分销层数量


@end


NS_ASSUME_NONNULL_END
