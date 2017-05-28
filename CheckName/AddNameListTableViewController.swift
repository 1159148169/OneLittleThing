//
//  AddNameListTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/9.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit

protocol AddItemViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: AddNameListTableViewController)
    func addItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishAdding item: NameItem)
    func editItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishEditing item: NameItem)
}

struct PostNotificationName {
    static let Finish10Post = Notification.Name(rawValue: "Finish10")
    static let Finish50Post = Notification.Name(rawValue: "Finish50")
    static let Finish100Post = Notification.Name(rawValue: "Finish100")
    static let Finish500Post = Notification.Name(rawValue: "Finish500")
    static let Finish1000Post = Notification.Name(rawValue: "Finish1000")
}

class AddNameListTableViewController: UITableViewController,UITextFieldDelegate {
    
    var archivementDataArray = [NSData]()
    
    weak var delegate:AddItemViewControllerDelegate?
    
    var nameToEdit:NameItem?
    
    var dueDate = Date()
    
    //var datePickerVisible = false //datePicker默认不显示
    
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var doneBarButtonItem:UIBarButtonItem!
    
    @IBOutlet weak var shouldImportantSwitch:UISwitch!
    @IBOutlet weak var shouldRemindMeSwitch:UISwitch!
    @IBOutlet weak var ifAddToAppleCalendar:UISwitch!
    @IBOutlet weak var dueDateLabel:UILabel!
    
    @IBAction func shouldImportant(_ sender: UISwitch) {
        textField.resignFirstResponder()
        
        if sender.isOn {
            let importantBanner = Banner(title: "已设置为重要",backgroundColor: UIColor(red:0.0/255.0, green:191.0/255.0, blue:255.5/255.0, alpha:1.000))
            importantBanner.dismissesOnTap = true
            importantBanner.show(duration: 1.0)
        } else {
            let importantBanner = Banner(title: "已取消设置为重要",backgroundColor: UIColor(red:0.0/255.0, green:191.0/255.0, blue:255.5/255.0, alpha:1.000))
            importantBanner.dismissesOnTap = true
            importantBanner.show(duration: 1.0)
        }
    }
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { //iOS10向用户申请通知权限
                
                granted, error in /* do nothing */
                
            }
            let remindBanner = Banner(title: "已设置提醒",backgroundColor: UIColor(red:255.0/255.0, green:165.0/255.0, blue:0.0/255.0, alpha:1.000))
            remindBanner.dismissesOnTap = true
            remindBanner.show(duration: 1.0)
        } else {
            let remindBanner = Banner(title: "已关闭提醒",backgroundColor: UIColor(red:255.0/255.0, green:165.0/255.0, blue:0.0/255.0, alpha:1.000))
            remindBanner.dismissesOnTap = true
            remindBanner.show(duration: 1.0)
        }
    }
    
    @IBAction func ifAddToAppleCalendarOrNot(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        
        if switchControl.isOn {
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                
            })
            let addToAppleCalendarBanner = Banner(title: "已添加到系统日历",backgroundColor: UIColor.red)
            addToAppleCalendarBanner.dismissesOnTap = true
            addToAppleCalendarBanner.show(duration: 1.0)
        } else {
            let addToAppleCalendarBanner = Banner(title: "已取消添加到系统日历",backgroundColor: UIColor.red)
            addToAppleCalendarBanner.dismissesOnTap = true
            addToAppleCalendarBanner.show(duration: 1.0)
        }
    }
    
    @IBAction func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        
        let planDoneNum = UserDefaults.standard.integer(forKey: "PlanAllDoneNum")
        UserDefaults.standard.set(planDoneNum + 1, forKey: "PlanAllDoneNum") // 从0开始
//        print(planDoneNum)
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        if let nameToEdit = nameToEdit { //nameToEdit
            nameToEdit.name = textField.text!
            
            nameToEdit.shouldImportant = shouldImportantSwitch.isOn
            nameToEdit.shouldRemind = shouldRemindMeSwitch.isOn
            nameToEdit.dueDate = dueDate
            nameToEdit.nowDate = Date()
            nameToEdit.shouldAddToAppleCalendar = ifAddToAppleCalendar.isOn
            
            nameToEdit.scheduleNotification()
            
            hudView.text = "已更新"
            
            if ifAddToAppleCalendar.isOn {
                let eventStore = EKEventStore()
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = nameToEdit.name
                if nameToEdit.shouldRemind == true {
                    event.startDate = nameToEdit.dueDate
                    event.endDate = nameToEdit.dueDate
                } else {
                    event.startDate = Date()
                    event.endDate = Date()
                }
                event.notes = "来自--小事一桩"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Saved Event")
                } catch {
                }
            }
            
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                self.delegate?.editItemViewControllerDidDone(self, didFinishEditing: nameToEdit)
            })
            
        } else {
            let newName = NameItem() //newName
            newName.name = textField.text!
            newName.charge = false
            
            newName.shouldImportant = shouldImportantSwitch.isOn
            newName.shouldRemind = shouldRemindMeSwitch.isOn
            newName.dueDate = dueDate
            newName.nowDate = Date()
            newName.shouldAddToAppleCalendar = ifAddToAppleCalendar.isOn
            
            newName.scheduleNotification()
            
            hudView.text = "已添加"
            
            if ifAddToAppleCalendar.isOn {
                let eventStore = EKEventStore()
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = newName.name
                if newName.shouldRemind == true {
                    event.startDate = newName.dueDate
                    event.endDate = newName.dueDate
                } else {
                    event.startDate = Date()
                    event.endDate = Date()
                }
                event.notes = "来自--小事一桩"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Saved Event")
                } catch {
                }
            }
            
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                self.delegate?.addItemViewControllerDidDone(self, didFinishAdding: newName)
                
                
                switch planDoneNum {
                    
                case 9:
                    
                    let archivement = Archivement()
                    archivement.title = "初出茅庐"
                    archivement.subTitle = "新建了10个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 10010
                    
                    // 先从UserDefults中读取成就数据
                    if UserDefaults.standard.array(forKey: "Archive") == nil {
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    } else {
                        self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    }
                    
                    NotificationCenter.default.post(name: PostNotificationName.Finish10Post, object: nil)
                    
                case 49:
                    
                    let archivement = Archivement()
                    archivement.title = "小试牛刀"
                    archivement.subTitle = "新建了50个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 10050
                    
                    // 先从UserDefults中读取成就数据
                    if UserDefaults.standard.array(forKey: "Archive") == nil {
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    } else {
                        self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    }
                    
                    NotificationCenter.default.post(name: PostNotificationName.Finish50Post, object: nil)
                    
                case 99:
                    
                    let archivement = Archivement()
                    archivement.title = "记录达人"
                    archivement.subTitle = "新建了100个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 10100
                    
                    // 先从UserDefults中读取成就数据
                    if UserDefaults.standard.array(forKey: "Archive") == nil {
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    } else {
                        self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    }
                    
                    NotificationCenter.default.post(name: PostNotificationName.Finish100Post, object: nil)
                    
                case 499:
                    
                    let archivement = Archivement()
                    archivement.title = "排山倒海"
                    archivement.subTitle = "新建了500个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 10500
                    
                    // 先从UserDefults中读取成就数据
                    if UserDefaults.standard.array(forKey: "Archive") == nil {
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    } else {
                        self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    }
                    
                    NotificationCenter.default.post(name: PostNotificationName.Finish500Post, object: nil)
                    
                case 999:
                    
                    let archivement = Archivement()
                    archivement.title = "6666"
                    archivement.subTitle = "新建了1000个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 11000
                    
                    // 先从UserDefults中读取成就数据
                    if UserDefaults.standard.array(forKey: "Archive") == nil {
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    } else {
                        self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
                        // 然后将新的成就数据添加到数组中
                        let archivementData = NSKeyedArchiver.archivedData(withRootObject: archivement)
                        self.archivementDataArray.append(archivementData as NSData)
                        // 最后将新的数组存入UserDefults
                        UserDefaults.standard.set(self.archivementDataArray, forKey: "Archive")
                    }
                    
                    NotificationCenter.default.post(name: PostNotificationName.Finish1000Post, object: nil)
                    
                default:
                    break
                }
                
                
            })
            
        }
    }
    
    override func viewDidLoad() {
        
        //以下代码自定义了一个手势用来隐藏键盘
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false //不取消点击处的其它action
        tableView.addGestureRecognizer(tapGestureRecognizer)
        
        if let nameToEdit = nameToEdit {
            title = "编辑计划"
            textField.text = nameToEdit.name
            doneBarButtonItem.isEnabled = true
            shouldImportantSwitch.isOn = nameToEdit.shouldImportant
            shouldRemindMeSwitch.isOn = nameToEdit.shouldRemind
            dueDate = nameToEdit.dueDate
            ifAddToAppleCalendar.isOn = nameToEdit.shouldAddToAppleCalendar
        }
        updateDueDateLabel()
    }
    
    /*隐藏键盘(此方法对tableView无效,仅对View有效)
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     self.view.endEditing(true)
     self.tableView.endEditing(true)
     }*/
    
    /*override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //此行代码作用未知,需要再研究
     return nil
     }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 3 {
            showDatePicker()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length > 0 {
            doneBarButtonItem.isEnabled = true
        } else {
            doneBarButtonItem.isEnabled = false
        }
        
        return true
    }
    
    func updateDueDateLabel() { //更新标签上的时间(系统实时时间)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func showDatePicker() {
        //datePickerVisible = true
        //let indexPathDatePicker = IndexPath(row: 2, section: 1)
        //tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        
        let picker = DateTimePicker.show()
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            // do something after tapping done
            self.dueDate = picker.selectedDate
            self.updateDueDateLabel()
        }
    }
    
    //隐藏键盘
    func hideKeyboard() {
        self.tableView.endEditing(true)
    }
    
}
