//
//  QuickPlanTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/1/15.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class QuickPlanTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,AddItemViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var allType: [TypeListItem] //快速计划种类
    var quick: TypeListItem
    var count = 0
    
    required init?(coder aDcoder: NSCoder) { //必须对allType和quick初始化
        allType = [TypeListItem]()
        quick = TypeListItem(name: "快速计划")
        quick.typeImage = UIImage(named: "Quick")!
        quick.typeImageView = UIImageView(image: quick.typeImage)
        super.init(coder: aDcoder)
        loadChecklist() //必须放在父类初始化方法之后
        for _ in allType {
            if allType[count].name == "快速计划" {
                break
            }
            count += 1
        }
        if count >= allType.count { //.plist文件中无"快速计划"这个种类
            allType.append(quick)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 100 //改变row高度
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allType[count].items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickPlanCell", for: indexPath) as! TypeTableViewCell
        
        cell.tintColor = UIColor.lightGray
        
        cell.accessoryType = .none
        cell.accessoryView = cell.typeAccessoryButton
        
        let label = cell.viewWithTag(250) as! UILabel
        let importantLabel = cell.viewWithTag(251) as! UILabel
        let remindTimeLabel = cell.viewWithTag(252) as! UILabel
        let nowTimeLabel = cell.viewWithTag(254) as! UILabel
        
        let item = allType[count].items[indexPath.row]
        item.superTypeName = allType[count].name
        
        
        
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
            //            label.textColor = UIColor.red
            //            importantLabel.textColor = UIColor.red
            importantLabel.attributedText = NSAttributedString(string: "这个计划很重要!", attributes: rememberAndImportantAttributes)
            //            remindTimeLabel.textColor = UIColor.red
        } else {
            //            label.textColor = UIColor.black
            //            importantLabel.textColor = UIColor.darkGray
            importantLabel.attributedText = NSAttributedString(string: "合理规划并管理你的生活", attributes: rememberAndImportantAttributes)
            //            remindTimeLabel.textColor = UIColor.darkGray
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
        
        // Configure the cell...
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "删除", backgroundColor: UIColor.red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("Convenience callback for swipe buttons!")
            let cellIndexPath = self.tableView.indexPath(for: cell)!
            self.allType[self.count].items.remove(at: cellIndexPath.row)
            let indexPaths = [cellIndexPath]
            tableView.deleteRows(at: indexPaths, with: .fade)
            self.saveChecklist()
            if self.allType[self.count].items.count == 0 { //每次删除cell后调用tableView.reloadData()特别消耗资源,这里做了优化
                tableView.reloadData()
            }
            return true
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
                
                return true
            })]
            cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
        }
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) { //解决空白页错位,在计划类别列表有同样的问题,暂时未解
        super.viewDidAppear(true)
        self.tableView.reloadData()
        
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
        //cell会重用,不要用cell存储数据,也就是说不要用cell做DataModel
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
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddQuickPlan" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddNameListTableViewController
            //MARK:-设置delegate最后一步
            controller.delegate = self
        } else if segue.identifier == "EditQuickPlan" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddNameListTableViewController
            controller.delegate = self
            //检测到是编辑功能,为nameToEdit赋值
            let countCell = superUITableViewCell(of: sender as! UIButton)
            if let indexPath = tableView.indexPath(for: countCell!) {
                controller.nameToEdit = allType[count].items[indexPath.row]
                print("6666")
            }
        }
            
        else if segue.identifier == "ShowDetail" {
            let detailController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let item = allType[count].items[indexPath.row]
            detailController.items = item
            detailController.typeNames = allType[count].name
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
        let item = allType[count].items[indexPath.row]
        let label = cell.viewWithTag(253) as! UILabel
        
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
        saveChecklist()
        
    }
    
    func addItemViewControllerDidCancel(_ controller: AddNameListTableViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishAdding item: NameItem) {
        let newRowIndex = allType[count].items.count
        allType[count].items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        saveChecklist()
        tableView.reloadData()
    }
    
    func editItemViewControllerDidDone(_ controller: AddNameListTableViewController, didFinishEditing item: NameItem) {
        if let index = allType[count].items.index(of: item) { //这个方法需要数据模型继承NSObject类
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                let label = cell.viewWithTag(250) as! UILabel
                label.text = item.name
            }
        }
        saveChecklist()
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    //本地数据的保存和读取(.plist文件保存)
    func documentsDirectory() -> URL { //获取沙盒文件夹路径
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL { //获取数据文件地址
        print(documentsDirectory().appendingPathComponent("Checklists.plist"))
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    func saveChecklist() {
        let data = NSMutableData() //数据存储在NSMutableData对象中
        //声明一个归档处理对象
        let archiver = NSKeyedArchiver(forWritingWith: data) //NSKeyedArchiver创建一个.plist文件并且把数据编码使其能够写入文件中
        //将quick以对应关键字进行编码
        archiver.encode(allType, forKey: "Checklists")
        //编码结束
        archiver.finishEncoding()
        //数据写入
        data.write(to: dataFilePath(), atomically: true)
        print("写入成功")
    }
    func loadChecklist() {
        //获取本地文件数据地址
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) { //try命令试图创建一个Data对象,如果创建失败就返回nil
            //解码器
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            //通过归档时设置的关键字还原quick
            allType = unarchiver.decodeObject(forKey: "Checklists") as! [TypeListItem]
            //结束编码
            unarchiver.finishDecoding()
            print("读取成功")
        }
    }
    
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyPage.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "你的快速计划会保存在这里"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "这里不需要给你的计划分类\n有些时候，快即是好\n点击右上角的 + 新建一个快速计划"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(14.0)), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(17.0))]
        return NSAttributedString(string: "Come on!", attributes: attributes)
        
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
