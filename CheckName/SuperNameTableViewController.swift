//
//  SuperNameTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 14/11/2016.
//  Copyright © 2016 Shi Feng. All rights reserved.
//

import UIKit

class SuperNameTableViewController: UITableViewController,AddNewListTypeDelegate,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addTypeButton: UIBarButtonItem!
    
    var lists:[TypeListItem]
    
    // 引导页变量
    var helpItems = [KSGuideItem]()
    
    required init?(coder aDcoder: NSCoder) {
        lists = [TypeListItem]()
        super.init(coder: aDcoder)
        loadChecklist()
        //以下循环用来测试
        /*for list in lists {
         let name = NameItem()
         name.name = "Item for \(list.name)"
         list.items.append(name)
         }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().tapGestureRecognizer()
        self.tableView.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none //去除cell之间的分割线
        
        self.tableView.rowHeight = 100 //改变row高度
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }
    
    override func viewDidAppear(_ animated: Bool) { //需要深刻理解ViewController的生命周期
        super.viewDidAppear(true)
        
        //MARK: - 有时间再仔细看一下这里
        saveChecklist() //加在这里不会crash,原因未知,调试程序感觉要死了
        
        tableView.reloadData() //当调用viewWillAppear方法时程序第一次启动会出现空白页错位的情况,原因未知
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveChecklist()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TypeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuperNameListCell", for: indexPath) as! TypeTableViewCell
        
        let listTypeLabel = cell.viewWithTag(2000) as! UILabel
        let remainNumLabel = cell.viewWithTag(2001) as! UILabel
        
        let item = lists[indexPath.row]
        let finishNum = item.countItemChecked()
        listTypeLabel.text = item.name
        cell.imgBack.image = item.typeImage
        
        if item.items.count == 0 {
            remainNumLabel.text = "还未添加计划"
        } else {
            if finishNum == 0 {
                remainNumLabel.text = "很棒!计划已全部完成!"
            } else {
                remainNumLabel.text = "还剩\(item.countItemChecked())个计划未完成"
            }
        }
        
        // Configure the cell...
        
        //configure right buttons
        
        cell.rightButtons = [MGSwipeButton(title: "删除", backgroundColor: UIColor.red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("Convenience callback for swipe buttons!")
            let cellIndexPath = self.tableView.indexPath(for: cell)!
            for i in 0 ..< self.lists[cellIndexPath.row].items.count {
                self.lists[cellIndexPath.row].items[i].removeNotification()
                print("从计划类型页面删除!")
            }
            
            //删除整个类别下的计划数目(改变应用角标)
            let planNotDone = UserDefaults.standard.integer(forKey: "GetPlanNotFinished")
            UserDefaults.standard.set(planNotDone - self.lists[cellIndexPath.row].items.count, forKey: "GetPlanNotFinished")
            UIApplication.shared.applicationIconBadgeNumber = planNotDone - self.lists[cellIndexPath.row].items.count
            
            self.lists.remove(at: cellIndexPath.row)
            self.saveChecklist()
            let indexPaths = [cellIndexPath]
            tableView.deleteRows(at: indexPaths, with: .fade)
            if self.lists.count == 0 { //每次删除cell后调用tableView.reloadData()特别消耗资源,这里做了优化
                tableView.reloadData()
            }
            return true
        })]
        
        cell.rightSwipeSettings.transition = MGSwipeTransition.clipCenter
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let typeNames = lists[indexPath.row]
        performSegue(withIdentifier: "ShowDetail", sender: typeNames)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if #available(iOS 10.0, *) {
                let controller = segue.destination as! CheckNameTableViewController
                controller.typeNames = sender as! TypeListItem
            } else {
                // Fallback on earlier versions
            }  }
        else if segue.identifier == "AddType" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! NewTypeListTableViewController
            controller.delegate = self //self指的是SuperNameTableViewController
        }
    }
    
    //自定义协议中方法的实现
    func touchChooseTypeList(_ controller: NewTypeListTableViewController, didFinishingAdding type: TypeListItem) {
        let newRowIndex = lists.count
        lists.append(type)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
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
        //将lists以对应关键字进行编码
        archiver.encode(lists, forKey: "Checklists")
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
            //通过归档时设置的关键字还原lists
            lists = unarchiver.decodeObject(forKey: "Checklists") as! [TypeListItem]
            //结束编码
            unarchiver.finishDecoding()
            print("读取成功")
        }
    }
    
    //展示引导页
    func showHelp(_ helpButton: UIButton!) {
        // Reset to show everytime.
         KSGuideDataManager.reset(for: "MainGuide")
        
        let helpItem = KSGuideItem(sourceView: helpButton, text: "这是一个简短的使用帮助,可以让你更快地了解如何使用该应用:\n\n这个页面用来添加计划的类别,然后你可以在对应的类别中添加计划\n\n每个计划都可以设置不同的属性,在添加或编辑计划时你就会看到\n\n侧滑菜单中将计划以不同的种类做了区分,你可以在侧滑菜单中找到更多有用的帮助信息~\n")
        helpItems.append(helpItem)
        let vc = KSGuideController(items: helpItems, key: "MainGuide")
        vc.setIndexChangeBlock { (index, item) in
            print("Index has change to \(index)")
        }
        vc.show(from: self) {
            print("Guide controller has been dismissed")
        }
        helpItems.removeAll()
    }
    
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyPage.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "准备好开始有计划的生活了吗"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "这里你将自己的计划分类以使得计划更有条理\n点击右上角的 + 选择一个类别\n侧滑菜单可以帮助你更好地管理自己\n马上开始有计划的生活"
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
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        showHelp(button)
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
