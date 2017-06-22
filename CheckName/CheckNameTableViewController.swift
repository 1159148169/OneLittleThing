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
    
    var archivementDataArray = [NSData]()
    
    /*required init?(coder aDcoder: NSCoder) { //在类的构造器前添加required修饰符表明所有该类的子类都必须实现该构造器,重写父类中必要的制定构造器时不需要添加override修饰符
     //如果子类继承的构造器能满足必要构造器的要求,则无须在子类中显式提供必要构造器的实现
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
        item.superTypeName = typeNames.name
        
        
        
        // 设置计划字体及下划线格式，用作删除线
        var attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 20)];
        
        if item.charge == true {
            attributes[NSForegroundColorAttributeName] = UIColor.lightGray
            attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
        } else {
            attributes[NSForegroundColorAttributeName] = UIColor.black
        }
        label.attributedText = NSAttributedString(string: item.name, attributes: attributes)
        
        // 设置重要、提醒字体及下划线格式，用作删除线
        var rememberAndImportantAttributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 13)];
        
        if item.charge == true {
            rememberAndImportantAttributes[NSForegroundColorAttributeName] = UIColor.lightGray
            rememberAndImportantAttributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
        } else {
            rememberAndImportantAttributes[NSForegroundColorAttributeName] = UIColor.darkGray
        }
        
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let nowTimeFormatter = DateFormatter()
        nowTimeFormatter.dateFormat = "MM月dd日"
        nowTimeLabel.text = nowTimeFormatter.string(from: item.nowDate)
        
        if item.shouldImportant == true {
            importantLabel.attributedText = NSAttributedString(string: "这个计划很重要!", attributes: rememberAndImportantAttributes)
        } else {
            importantLabel.attributedText = NSAttributedString(string: "合理规划并管理你的生活", attributes: rememberAndImportantAttributes)
        }
        if item.shouldRemind == true {
            remindTimeLabel.attributedText = NSAttributedString(string: "\(formatter.string(from: item.dueDate)) 前完成", attributes: rememberAndImportantAttributes)
        } else {
            remindTimeLabel.attributedText = NSAttributedString(string: "未设定提醒时间", attributes: rememberAndImportantAttributes)
        }
        
        if item.charge == true { //对勾选中不通知(这种做法比较消耗资源,暂未想到更好的方法)
            item.removeNotification()
        } else {
            item.scheduleNotification()
        }
        
        configureCheckmark(for: cell, at: indexPath)
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "删除", backgroundColor: UIColor.red, callback: { [weak self]
            (sender: MGSwipeTableCell!) -> Bool in
            if let strongSelf = self {
                print("Convenience callback for swipe rightButtons!")
                let cellIndexPath = strongSelf.tableView.indexPath(for: cell)!
                strongSelf.typeNames.items[cellIndexPath.row].removeNotification()
                strongSelf.typeNames.items.remove(at: cellIndexPath.row)
                let indexPaths = [cellIndexPath]
                tableView.deleteRows(at: indexPaths, with: .fade)
                if strongSelf.typeNames.items.count == 0 { //每次删除cell后调用tableView.reloadData()特别消耗资源,这里做了优化
                    tableView.reloadData()
                }
                return true
            } else {
                return false
            }
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.clipCenter
        
        if item.charge == true {
            cell.leftButtons = [MGSwipeButton(title: "还未完成", backgroundColor: UIColor.darkGray, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("Convenience callback for swipe leftButtons!")
                item.toggleCharge()
                self.configureCheckmark(for: cell, at: indexPath)
                tableView.reloadData()
                
                return true
            })]
            cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
        } else {
            cell.leftButtons = [MGSwipeButton(title: "已完成", backgroundColor: UIColor.darkGray, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("Convenience callback for swipe leftButtons!")
                item.toggleCharge()
                self.configureCheckmark(for: cell, at: indexPath)
                tableView.reloadData()
                
                let planFinishedNum = UserDefaults.standard.integer(forKey: "PlanAllFinishedNum")
                UserDefaults.standard.set(planFinishedNum + 1, forKey: "PlanAllFinishedNum") // 从0开始
                
                switch planFinishedNum {
                    
                case 9:
                    let archivement = Archivement()
                    archivement.title = "经验宝宝"
                    archivement.subTitle = "完成了10个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 20010
                    
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
                    
                    let alert = UIAlertController(title: "很棒", message: "你已经完成了10个计划,并且获得了\"经验宝宝\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case 49:
                    let archivement = Archivement()
                    archivement.title = "浪里个浪"
                    archivement.subTitle = "完成了50个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 20050
                    
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
                    
                    let alert = UIAlertController(title: "很棒", message: "你已经完成了50个计划,并且获得了\"浪里个浪\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case 99:
                    let archivement = Archivement()
                    archivement.title = "计划达人"
                    archivement.subTitle = "完成了100个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 20100
                    
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
                    
                    let alert = UIAlertController(title: "很棒", message: "你已经完成了100个计划,并且获得了\"计划达人\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case 499:
                    let archivement = Archivement()
                    archivement.title = "走火入魔"
                    archivement.subTitle = "完成了500个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 20500
                    
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
                    
                    let alert = UIAlertController(title: "哇塞", message: "你已经完成了500个计划,并且获得了\"走火入魔\"勋章!Amazing!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                case 999:
                    let archivement = Archivement()
                    archivement.title = "6得不行"
                    archivement.subTitle = "完成了1000个计划后获得"
                    archivement.picURL = ""
//                    archivement.kind = 21000
                    
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
                    
                    let alert = UIAlertController(title: "天啊", message: "你已经完成了1000个计划!这枚\"6得不行\"勋章是你的了!简直不敢相信!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                
                return true
            })]
            cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
        }
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(forName: PostNotificationName.Finish10Post, object: nil, queue: OperationQueue.main) { (Notification) in
            // 添加了10个计划
            let alert = UIAlertController(title: "很棒", message: "你已经做了10个计划,并且获得了\"初出茅庐\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
        NotificationCenter.default.addObserver(forName: PostNotificationName.Finish50Post, object: nil, queue: OperationQueue.main) { (Notification) in
            // 添加了50个计划
            let alert = UIAlertController(title: "很棒", message: "你已经做了50个计划,并且获得了\"小试牛刀\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
        NotificationCenter.default.addObserver(forName: PostNotificationName.Finish100Post, object: nil, queue: OperationQueue.main) { (Notification) in
            // 添加了100个计划
            let alert = UIAlertController(title: "很棒", message: "你已经做了100个计划,并且获得了\"记录达人\"勋章!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
        NotificationCenter.default.addObserver(forName: PostNotificationName.Finish500Post, object: nil, queue: OperationQueue.main) { (Notification) in
            // 添加了500个计划
            let alert = UIAlertController(title: "哇塞", message: "你已经做了500个计划,并且获得了\"排山倒海\"勋章!这简直不可思议!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
        NotificationCenter.default.addObserver(forName: PostNotificationName.Finish1000Post, object: nil, queue: OperationQueue.main) { (Notification) in
            // 添加了1000个计划
            let alert = UIAlertController(title: "天哪!", message: "你已经做了1000个计划!连我都不得不说你简直太棒了!这枚\"6666\"勋章是你的了!现在你可以在\"我的成就\"列表中查看你的成就!", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        
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
            
        else if segue.identifier == "ShowDetail" {
            let detailController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let item = typeNames.items[indexPath.row]
            detailController.items = item
            detailController.typeNames = typeNames.name
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
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
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
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi/2), 0.0, 0.0, 1.0))
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
