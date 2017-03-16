//
//  NameListItem.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/7.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import Foundation
import UserNotifications

class NameItem:NSObject,NSCoding {
    var name:String = ""
    var charge = false
    
    var dueDate = Date()
    var nowDate = Date()
    var shouldImportant = false
    var shouldRemind = false
    var itemID: Int
    
    override init() { //删掉会导致程序无法运行
        itemID = NameItem.nextCheckListItmeID()
        super.init()
    }
    
    func toggleCharge() {
        charge = !charge
    }
    
    //下面这两个方法是遵循NSCoding协议
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Text")
        aCoder.encode(charge, forKey: "Checked")
        aCoder.encode(dueDate, forKey: "Date")
        aCoder.encode(nowDate, forKey: "Now")
        aCoder.encode(shouldImportant, forKey: "Important")
        aCoder.encode(shouldRemind, forKey: "Remind")
        aCoder.encode(itemID, forKey: "ID")
    }
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Text") as! String
        charge = aDecoder.decodeBool(forKey: "Checked")
        dueDate = aDecoder.decodeObject(forKey: "Date") as! Date
        nowDate = aDecoder.decodeObject(forKey: "Now") as! Date
        shouldImportant = aDecoder.decodeBool(forKey: "Important")
        shouldRemind = aDecoder.decodeBool(forKey: "Remind")
        itemID = aDecoder.decodeInteger(forKey: "ID")
        super.init()
    }
    
    class func nextCheckListItmeID() -> Int {
        let userDefults = UserDefaults.standard
        let itemID = userDefults.integer(forKey: "ID")
        userDefults.set(itemID + 1, forKey: "ID")
        userDefults.synchronize()
        return itemID
    }
    
    //添加通知
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            
            let content = UNMutableNotificationContent()
            content.title = "记得完成你的计划:"
            content.body = name
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month,.day,.hour,.minute], from: dueDate) //从dueDate中把年月日小时分钟挑出来
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests( withIdentifiers: ["\(itemID)"])
    }
    
    deinit { //当主页面的cell或子页面的cell被删除时调用析构方法
        removeNotification()
    }
    
}

class TypeListItem:NSObject,NSCoding { //对数据类型做了修改实现了不同的Cell对应不同的界面
    var name = ""
    
    var typeDetail = "" //暂时不解析
    var typeImage = UIImage()
    var typeImageView = UIImageView()
    
    var items = [NameItem]() //思路很巧妙
    
    init(name:String) { //构造方法
        self.name = name
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { //从object解析回来
        name = aDecoder.decodeObject(forKey: "Name") as! String
        typeImage = aDecoder.decodeObject(forKey: "TypeImage") as! UIImage
        typeImageView = aDecoder.decodeObject(forKey: "TypeImageView") as! UIImageView
        //typeDetail = aDecoder.decodeObject(forKey: "TypeDetail") as! String
        items = aDecoder.decodeObject(forKey: "Items") as! [NameItem]
        super.init()
    }
    
    func encode(with aCoder: NSCoder) { //编码成object
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(typeImage, forKey: "TypeImage")
        aCoder.encode(typeImageView, forKey: "TypeImageView")
        //aCoder.encode(typeDetail, forKey: "TypeDetail")
        aCoder.encode(items, forKey: "Items")
    }
    
    //计算未打钩的计划个数
    func countItemChecked() -> Int {
        var count = 0
        for name in items where !name.charge{
            count += 1
        }
        return count
    }
}
