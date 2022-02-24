//
//  AppDelegate.m
//  集成百度地图
//
//  Created by Hello Cai on 2022/2/15.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>// 引入base相关所有的头文件
#import <BMKLocationKit/BMKLocationComponent.h>//引入定位相关的头文件

#define BaiduMapKey @"nL1kcMElGGivD66OHGrUc64scETyQAYl"

@interface AppDelegate ()
@property (strong, nonatomic) BMKMapManager *mapManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.mapManager = [[BMKMapManager alloc] init];
    if ([self.mapManager start:BaiduMapKey generalDelegate:nil]) {
        NSLog(@"启动百度地图manager成功");
    } else {
        NSLog(@"启动百度地图manager失败");
    }
    // 需要注意的是请在 SDK 任何类的初始化以及方法调用之前设置正确的Key
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BaiduMapKey authDelegate:nil];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
