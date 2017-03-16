//
//  CheckNameTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/3.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import UIKit

class CheckNameTableViewController: UITableViewController,AddItemViewControllerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    var typeNames:TypeListItem!
    
    /*required init?(coder aDcoder: NSCoder) { //在类的构造器前添加required修饰符表明所有该类的子类都必须实现该构造器,重写父类中必要的制定构造器时不需要添加override修饰符
        //如果子类继承的构造器能满足必要构造器的要求,则无须在子类中显式提供必要构造器的实现
        typeNames.items = [NameItem]()
        
        /*let item0 = NameItem()
        item0.name = "TangJian"
        item0.charge = false
        items.append(item0)
        
        let item1 = NameItem()
        item1.name = "ShiFeng"
        item1.charge = false
        items.append(item1)
        
        let item2 = NameItem()
        item2.name = "WangShuai"
        item2.charge = false
        items.append(item2)
        
        let item3 = NameItem()
        item3.name = "WangKai"
        item3.charge = false
        items.append(item3)
        
        let item4 = NameItem()
        item4.name = "LiJiesheng"
        item4.charge = false
        items.append(item4)*/
        super.init(coder: aDcoder)
     
        //loadChecklistItems()
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.title = typeNames.name
        self.tableView.rowHeight = 100 //改变row高度
        //self.tableView.reloadData() //在这里刷新会导致空白页面的标签位置错误
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeNames.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameListCell", for: indexPath) as! TypeTableViewCell
        cell.tintColor = UIColor.lightGray
        
        cell.accessoryType = .none
        cell.accessoryView = cell.typeAccessoryButton
        
        let label = cell.viewWithTag(1000) as! UILabel
        let importantLabel = cell.viewWithTag(1100) as! UILabel
        let remindTimeLabel = cell.viewWithTag(1200) as! UILabel
        let nowTimeLabel = cell.viewWithTag(1300) as! UILabel
        
        let item = typeNames.items[indexPath.row]
        
        label.text = item.name
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let nowTimeFormatter = DateFormatter()
        nowTimeFormatter.dateFormat = "MM月dd日"
//        nowTimeFormatter.dateStyle = .short
//        nowTimeFormatter.timeStyle = .none
//        print(item.nowDate)
//        print(nowTimeFormatter.string(from: item.nowDate))
        nowTimeLabel.text = nowTimeFormatter.string(from: item.nowDate)
        
        if item.shouldImportant == true {
            label.textColor = UIColor.red
            importantLabel.textColor = UIColor.red
            importantLabel.text = "这个计划很重要!"
            remindTimeLabel.textColor = UIColor.red
        } else {
            label.textColor = UIColor.black
            importantLabel.textColor = UIColor.darkGray
            importantLabel.text = "合理规划并管理你的生活"
            remindTimeLabel.textColor = UIColor.darkGray
        }
        if item.shouldRemind == true {
            remindTimeLabel.text = "\(formatter.string(from: item.dueDate)) 前完成"
        } else {
            remindTimeLabel.text = "未设定提醒时间"
        }
        
        if item.charge == true { //对勾选中不通知(这种做法比较消耗资源,暂未想到更好的方法)
            item.removeNotification()
        } else {
            item.scheduleNotification()
        }
        
        /*if item.charge == true {
            //如果计划完成就添加删除线
            let attribtStr = NSMutableAttributedString(string: item.name)
            attribtStr.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber(value: 1), range: NSMakeRange(0, 3))
            label.attributedText = attribtStr
            label.sizeToFit()
            
            self.view.addSubview(label)
        }*/
        
        configureCheckmark(for: cell, at: indexPath)
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "删除", backgroundColor: UIColor.red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("Convenience callback for swipe buttons!")
            let cellIndexPath = self.tableView.indexPath(for: cell)!
            self.typeNames.items.remove(at: cellIndexPath.row)
            let indexPaths = [cellIndexPath]
            tableView.deleteRows(at: indexPaths, with: .fade)
            if self.typeNames.items.count == 0 { //每次删除cell后调用tableView.reloadData()特别消耗资源,这里做了优化
                tableView.reloadData()
            }
            return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.clipCenter

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) { //cell会重用,不要用cell存储数据,也就是说不要用cell做DataModel
            /*
            下面的代码就是用cell保存点击后Checkmark的状态,是错误的
            */
            /*
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            */
            let item = typeNames.items[indexPath.row]
            if !item.charge {
                let checkAlert = UIAlertController(title: "你确定吗", message: "你已经完成了这个计划？", preferredStyle: .alert)
                let checkCancelAlertAction = UIAlertAction(title: "我手滑了", style: .cancel, handler: nil)
                let checkOKAlertAction = UIAlertAction(title: "已经完成", style: .default, handler: { (action) in
                    item.toggleCharge()
                    self.configureCheckmark(for: cell, at: indexPath)
                })
                checkAlert.addAction(checkCancelAlertAction)
                checkAlert.addAction(checkOKAlertAction)
                self.present(checkAlert, animated: true, completion: nil)
            } else {
                let checkAlert = UIAlertController(title: "你确定吗", message: "这是一个你已经完成的计划", preferredStyle: .alert)
                let checkCancelAlertAction = UIAlertAction(title: "我手滑了", style: .cancel, handler: nil)
                let checkOKAlertAction = UIAlertAction(title: "还未完成", style: .default, handler: { (action) in
                    item.toggleCharge()
                    self.configureCheckmark(for: cell, at: indexPath)
                })
                checkAlert.addAction(checkCancelAlertAction)
                checkAlert.addAction(checkOKAlertAction)
                self.present(checkAlert, animated: true, completion: nil)
            }
        
            tableView.deselectRow(at: indexPath, animated: true)
        }
        //saveChecklistItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddName" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddNameListTableViewController
            controller.delegate = self //设置delegate最后一步
        } else if segue.identifier == "EditName" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddNameListTableViewController
            controller.delegate = self
            //检测到是编辑功能,为nameToEdit赋值
            let countCell = superUITableViewCell(of: sender as! UIButton)
            if let indexPath = tableView.indexPath(for: countCell!) {
                controller.nameToEdit = typeNames.items[indexPath.row]
                print("6666")
            }
        }
    }
    
    //MARK:-返回button所在的UITableViewCell
    //通过遍历循环 button 的 superview 来获取其对应的 cell
    func superUITableViewCell(of: UIButton) -> TypeTableViewCell? {
        for view in sequence(first: of.superview, next: { $0?.superview }) {
            if let cell = view as? TypeTableViewCell {
                return cell
            }
        }
        return nil
    }
    
    func configureCheckmark(for cell:UITableViewCell, at indexPath:IndexPath) { //将对勾的默认状态变为不打钩
        var isChecked = false
        let item = typeNames.items[indexPath.row]
        let label = cell.viewWithTag(1001) as! UILabel
        
        /*let mainLabel = cell.viewWithTag(1000) as! UILabel
        let importantLabel = cell.viewWithTag(1100) as! UILabel
        let remindTimeLabel = cell.viewWithTag(1200) as! UILabel*/
        
        isChecked = item.charge
        
        if isChecked {
            label.text = "我已搞定"
            /*mainLabel.textColor = UIColor.gray
            importantLabel.textColor = UIColor.gray
            remindTimeLabel.textColor = UIColor.gray*/
        }
        else {
            label.text = ""
        }
        
    }
    
    func addItemViewControllerDidCancel(_ controller: AddNameListTableViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishAdding item: NameItem) {
        let newRowIndex = typeNames.items.count
        typeNames.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        //saveChecklistItems()
        tableView.reloadData()
    }
    
    func editItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishEditing item: NameItem) {
        if let index = typeNames.items.index(of: item) { //这个方法需要数据模型继承NSObject类
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                let label = cell.viewWithTag(1000) as! UILabel
                label.text = item.name
            }
        }
        //saveChecklistItems()
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    //保存和读取
    /*func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    func saveChecklistItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(typeNames.items, forKey: "ChecklistItems")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    func loadChecklistItems() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            typeNames.items = unarchiver.decodeObject(forKey: "ChecklistItems") as! [NameItem]
            unarchiver.finishDecoding()
        }
    }*/
    
    //实现第三方库协议的方法
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyPage.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "现在开始,计划你的第一步"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "这里列举了你在这个类别下的所有计划\n点击右上角的 + 就可以新建一个计划\n你可以随时编辑或删除你的计划\n希望我可以帮助你成为一个生活的管理者"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(14.0)), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)

    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(17.0))]
        return NSAttributedString(string: "让我们开始吧", attributes: attributes)

    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        //print("成功调用!")
        return UIColor.white
    }
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        //print("成功调用!")
        return animation
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
    

}
