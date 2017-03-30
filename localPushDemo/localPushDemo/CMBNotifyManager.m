//
//  CMBNotifyManager.m
//  localPushDemo
//
//  Created by Maria_Pang on 17/3/30.
//  Copyright © 2017年 Maria_Pang. All rights reserved.
//

#import "CMBNotifyManager.h"



@interface CMBNotifyManager ()

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



@end
