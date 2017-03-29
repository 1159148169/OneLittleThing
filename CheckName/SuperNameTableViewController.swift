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
    
    var lists:[TypeListItem]
    
    required init?(coder aDcoder: NSCoder) {
        lists = [TypeListItem]()
        /*let item0 = TypeListItem(name: "Study") //必须自己定义一个构造器
        lists.append(item0)
        
        let item1 = TypeListItem(name: "Sports")
        lists.append(item1)
        
        let item2 = TypeListItem(name: "Works")
        lists.append(item2)
        
        let item3 = TypeListItem(name: "Life")
        lists.append(item3)
        
        let item4 = TypeListItem(name: "Buy")
        lists.append(item4)
        
        let item5 = TypeListItem(name: "Others")
        lists.append(item5)*/
        
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
        
//        let panGestureRecognizer = UITapGestureRecognizer(target: self.revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)))
//        self.tableView.addGestureRecognizer(panGestureRecognizer)
        
        //判断屏幕是否支持3d touch
        /*if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView) //这里的sourceView指的是触发peek动作的view
        }*/
        
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
        
        //self.tableView.animateCells(animation: .left(duration: 1))
        //self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuperNameListCell", for: indexPath) as! TypeTableViewCell
        
//        //获取每一个cell之后,把cell注册给控制器,这样我们才可以在重按的时候显示Peek视图
//        self.registerForPreviewing(with: self, sourceView: cell) //使用控制器调用方法,注册previewAction的代理和视图
        
        let listTypeLabel = cell.viewWithTag(2000) as! UILabel
        let remainNumLabel = cell.viewWithTag(2001) as! UILabel
        
        let item = lists[indexPath.row]
        let finishNum = item.countItemChecked()
        listTypeLabel.text = item.name
        cell.backgroundView = item.typeImageView
        
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
            self.lists.remove(at: cellIndexPath.row)
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
            let controller = segue.destination as! CheckNameTableViewController
            controller.typeNames = sender as! TypeListItem
        }
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
        let text = "在这里你将自己的计划分类以使自己的计划更有条理\n点击右上角的 + 选择一个类别\n开始有计划的生活"
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
    
//    //实现peek和pop
//    //peek
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        
//        //建立新的控制器
//        
//        return nil
//    }
//    //pop
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//    }

}
