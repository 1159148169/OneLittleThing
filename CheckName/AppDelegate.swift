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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { //这个方法允许你在显示app给用户之前执行最后的初始化操作
        let centre = UNUserNotificationCenter.current() //为了实现UNUserNotificationCenterDelegate协议对应的方法
        centre.delegate = self
        
        //        if let barFont = UIFont(name: "AvenirNext", size: 25.0) {
        //            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:barFont]
        //        } //更改导航栏字体样式
        UINavigationBar.appearance().barTintColor =  UIColor.black //修改导航栏背景色
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white] //修改导航栏文字颜色
        UINavigationBar.appearance().tintColor = UIColor.white //修改导航栏按钮颜色
        
        UIApplication.shared.statusBarStyle = .lightContent //更改状态栏颜色来和导航栏字体颜色适配,在info里做过修改
        
        return true
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
        //        let navigationController = window!.rootViewController as! UINavigationController
        //        let controller = navigationController.viewControllers[0] as! SuperNameTableViewController
        let controllerStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = controllerStoryboard.instantiateViewController(withIdentifier: "TypeNavigation") as! UINavigationController
        print(navigationController.restorationIdentifier!)
        let controller = navigationController.viewControllers[0] as! SuperNameTableViewController
        print(controller.restorationIdentifier!)
        controller.saveChecklist()
    }
    
}
