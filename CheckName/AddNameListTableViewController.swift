//
//  AddNameListTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/9.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import UIKit
import UserNotifications

protocol AddItemViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: AddNameListTableViewController)
    func addItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishAdding item: NameItem)
    func editItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishEditing item: NameItem)
}

class AddNameListTableViewController: UITableViewController,UITextFieldDelegate {

    weak var delegate:AddItemViewControllerDelegate?
    
    var nameToEdit:NameItem?
    
    var dueDate = Date()
    
    //var datePickerVisible = false //datePicker默认不显示
    
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var doneBarButtonItem:UIBarButtonItem!
    
    @IBOutlet weak var shouldImportantSwitch:UISwitch!
    @IBOutlet weak var shouldRemindMeSwitch:UISwitch!
    @IBOutlet weak var dueDateLabel:UILabel!
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { //iOS10向用户申请通知权限
            
            granted, error in /* do nothing */
                
            }
        }
    }
    
    @IBAction func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        if let nameToEdit = nameToEdit { //nameToEdit
            nameToEdit.name = textField.text!
            
            nameToEdit.shouldImportant = shouldImportantSwitch.isOn
            nameToEdit.shouldRemind = shouldRemindMeSwitch.isOn
            nameToEdit.dueDate = dueDate
            nameToEdit.nowDate = Date()
            
            nameToEdit.scheduleNotification()
            
            hudView.text = "已更新"
            
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
            
            newName.scheduleNotification()
            
            hudView.text = "已添加"
            
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
                self.delegate?.addItemViewControllerDidDone(self, didFinishAdding: newName)
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
        
        if indexPath.section == 1 && indexPath.row == 2 {
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
