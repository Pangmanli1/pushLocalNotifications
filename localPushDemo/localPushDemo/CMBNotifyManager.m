//
//  CMBNotifyManager.m
//  localPushDemo
//
//  Created by Maria_Pang on 17/3/30.
//  Copyright © 2017年 Maria_Pang. All rights reserved.
//

#import "CMBNotifyManager.h"
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#import "NSDate+Utilities.h"
#import "NSString+Path.h"
#define IS_IOS7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IOS10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define ALARM_KEY          @"alarmKey"
#define ALARM_TYPE_DEFAULT @"alarmType_default"
#define FILE_NAME          @"alarmType"


@interface CMBNotifyManager ()

@property (nonatomic, strong) NSMutableArray *mesgTypeArray; //储存通知的类型

@end

@implementation CMBNotifyManager



+(instancetype)shareManager {
    
    static dispatch_once_t onceToken;
    static CMBNotifyManager * manager;
    dispatch_once(&onceToken, ^{
        
        manager = [[CMBNotifyManager alloc]init];
        
    });
    
    return manager;
}

#pragma mark-  几小时几分后开启通知,是否重复推送,相同的通知内容

+(void)notifi:(NSString*)title body:(NSString*)body fireHours:(NSInteger)hour  minute:(NSInteger)min titleisRepeat:(BOOL)isRepeat andIdentifier:(NSString*)identifier{
    
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    
    localNote.fireDate = [self getDateWithHour:hour andMin:min andSec:0];
    localNote.timeZone=[NSTimeZone defaultTimeZone];
    localNote.repeatInterval=kCFCalendarUnitMinute;
    localNote.alertTitle = title;
    localNote.alertBody = body;
    localNote.hasAction = YES;
    localNote.soundName = UILocalNotificationDefaultSoundName;
    localNote.applicationIconBadgeNumber = 1;
    localNote.userInfo = @{ALARM_KEY : ALARM_TYPE_DEFAULT};
    
    [self saveMesgType:ALARM_TYPE_DEFAULT];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];}

#pragma mark- 每周几,几点,几分 发送相同通知内容

/**
 缓存通知类型
 */
+(void)saveMesgType:(NSString *) mesgType{
    for (int i=0; [CMBNotifyManager shareManager].mesgTypeArray.count; i++)
    {
        if( YES == [[CMBNotifyManager shareManager].mesgTypeArray[i] isEqualToString:mesgType] )
        {
            NSLog(@"--NOTIFI：通知类型已经存在");
            return;
        }
    }
    
    NSLog(@"--NOTIFI：添加通知类型[%@]成功", mesgType);
    [[CMBNotifyManager shareManager].mesgTypeArray addObject:mesgType];
    bool isOk = [[CMBNotifyManager shareManager].mesgTypeArray writeToFile:[FILE_NAME appendDocuments] atomically:YES];
    if ( isOk ) {
        NSLog(@"--NOTIFI：序列化通知类型[%@]到本地失败", mesgType);
    }
}


/**
 删除该类型的所有通知
 */
+(void)deleteCancelLocalNotifi {
    NSArray * allLocalNotification=[[UIApplication sharedApplication] scheduledLocalNotifications];
    if ([allLocalNotification count] <= 0)
    {
        NSLog(@"--NOTIFI：系统通知数组为空");
        return;
    }
    
    for (UILocalNotification * oneNote in allLocalNotification)
    {
        NSString * mesgType = [oneNote.userInfo objectForKey:ALARM_KEY];
        
        if ([mesgType isEqualToString:ALARM_TYPE_DEFAULT])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:oneNote];
            NSLog(@"--NOTIFI：删除旧通知类型%@", mesgType);
        }
    }
}



/**
 生成日期根据(小时 分钟 秒)
 */

+(NSDate *)getDateWithHour:(NSInteger)hour andMin:(NSInteger)min andSec:(NSInteger)sec{
    //格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    
    hour = hour + min/60;
    
   NSInteger d = hour/24;
    
    //组装时间字符串
    NSDate *nowDate = [NSDate date];
    NSString *timeStr = [NSString stringWithFormat:@"%@年%@月%@日 %@:%@:%@",
                         @(nowDate.year),
                         @(nowDate.month),
                         @(nowDate.day+d),
                         @(hour),
                         @(min),
                         @(sec)];
    
    return [formatter dateFromString:timeStr];
}





@end
