//
//  AppDelegate.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/3.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    var lists = [TypeListItem]()
    var detailLists = [NameItem]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { //这个方法允许你在显示app给用户之前执行最后的初始化操作
        
        let centre = UNUserNotificationCenter.current() //为了实现UNUserNotificationCenterDelegate协议对应的方法
        centre.delegate = self
        
        UINavigationBar.appearance().barTintColor =  UIColor.black //修改导航栏背景色
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white] //修改导航栏文字颜色
        UINavigationBar.appearance().tintColor = UIColor.white //修改导航栏按钮颜色
        
        UIApplication.shared.statusBarStyle = .lightContent //更改状态栏颜色来和导航栏字体颜色适配,在info里做过修改
        
        //注册LeanCloud服务
        AVOSCloud.setApplicationId("CGM6nl02YaWaB2YzzrOjOwBf-gzGzoHsz" ,clientKey: "sHsacdDcvHSLsW6uKY4d4te9")
        
        //极光推送
        //通知类型（这里将声音、消息给加上，提醒小标也要加）
        let userSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
        if ((UIDevice.current.systemVersion as NSString).floatValue >= 8.0) {
            //可以添加自定义categories
            JPUSHService.register(forRemoteNotificationTypes: userSettings.types.rawValue,
                                  categories: nil)
        }
        else {
            //categories 必须为nil
            JPUSHService.register(forRemoteNotificationTypes: userSettings.types.rawValue,
                                  categories: nil)
        }
        
        // 启动JPushSDK
        JPUSHService.setup(withOption: nil, appKey: "8558fce51ccc13746a837f98",
                           channel: "Publish Channel", apsForProduction: false)
        // 注意：apsForProduction参数决定了推送适合的环境,false为开发环境
        
        //获取未完成计划数(必须放在注册通知后,在iOS中只有注册了通知才可以显示应用角标)
        if UserDefaults.standard.integer(forKey: "GetPlanNotFinished") == 0 {
            //从.plist文件中获取未完成的计划
            print("从.plist文件中获取未完成的计划")
            lists = getTypeName()!
            var count = 0
            //两层循环获取具体计划
            for _ in lists {
                for detail in lists[count].items {
                    if !detail.charge { //只有未完成的计划才添加
                        detailLists.append(detail)
                    }
                }
                count += 1
            }
            //保存到UserDefults中并以红点标记显示
            UserDefaults.standard.set(detailLists.count, forKey: "GetPlanNotFinished")
            UIApplication.shared.applicationIconBadgeNumber = detailLists.count
        } else {
            //从UserDefults中获取未完成的计划并以红点标记显示
            print("从UserDefults中获取未完成的计划并以红点标记显示")
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: "GetPlanNotFinished")
        }
        
        //自动更新错误的角标值(将实际UserDefults中的值与实际完成的计划作比较,如果不一致,以实际完成的计划为准)(增大了I/O,历史遗留问题)
        print("从.plist文件中获取未完成的计划")
        lists = getTypeName()!
        var count = 0
        //两层循环获取具体计划
        for _ in lists {
            for detail in lists[count].items {
                if !detail.charge { //只有未完成的计划才添加
                    detailLists.append(detail)
                }
            }
            count += 1
        }
        if UserDefaults.standard.integer(forKey: "GetPlanNotFinished") != count {
            UserDefaults.standard.set(count, forKey: "GetPlanNotFinished")
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: "GetPlanNotFinished")
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //注册 DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //增加IOS 7的支持
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //可选
        NSLog("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //saveData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }
    
    //用来监听本地通知是否收到
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("收到本地通知\(notification)")
    }
    
    func saveData() {
        let controllerStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = controllerStoryboard.instantiateViewController(withIdentifier: "TypeNavigation") as! UINavigationController
        print(navigationController.restorationIdentifier!)
        let controller = navigationController.viewControllers[0] as! SuperNameTableViewController
        print(controller.restorationIdentifier!)
        controller.saveChecklist()
    }
    
    func documentsDirectory() -> URL { //获取沙盒文件夹路径
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL { //获取数据文件地址
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    func getTypeName() -> [TypeListItem]? {
        //获取本地文件数据地址
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) { //try命令试图创建一个Data对象,如果创建失败就返回nil
            //解码器
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            //通过归档时设置的关键字还原lists
            lists = unarchiver.decodeObject(forKey: "Checklists") as! [TypeListItem]
            //结束编码
            unarchiver.finishDecoding()
        }
        return lists
    }
}
