//
//  TimePlanTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/1/15.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class TimePlanTableViewController: UITableViewController,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    @IBAction func changeEdit() {
        let alert = UIAlertController(title: "哦...", message: "在这里你不能编辑计划", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    var lists:[TypeListItem]
    var detailLists:[NameItem]
    
    required init?(coder aDcoder: NSCoder) {
        lists = [TypeListItem]()
        detailLists = [NameItem]()
        super.init(coder: aDcoder)
        //loadChecklist()
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

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
    
    override func viewWillAppear(_ animated: Bool) {
        lists = getTypeName()!
        var count = 0
        
        //MARK:-两层循环获取具体计划
        for _ in lists {
            for detail in lists[count].items {
                detailLists.append(detail)
            }
            count += 1
        }
        self.sortDetailLists() //放到viewDidLoad方法中是不起作用的,这里依然体现了ViewController生命周期的理解不到位
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
        return detailLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimePlanCell", for: indexPath)
        cell.accessoryType = .none
        cell.accessoryView = cell.viewWithTag(355) as! UIButton
        
        let timePlanLabel = cell.viewWithTag(350) as! UILabel
        let importantLabel = cell.viewWithTag(351) as! UILabel
        let remainTimeLabel = cell.viewWithTag(352) as! UILabel
        let finishMarkLabel = cell.viewWithTag(353) as! UILabel
        let nowTimeLabel = cell.viewWithTag(354) as! UILabel
        
        let item = detailLists[indexPath.row]
        timePlanLabel.text = item.name
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let nowTimeFormatter = DateFormatter()
        nowTimeFormatter.dateFormat = "MM月dd日"
        nowTimeLabel.text = nowTimeFormatter.string(from: item.nowDate)
        
        if item.shouldImportant == true {
            timePlanLabel.textColor = UIColor.red
            importantLabel.textColor = UIColor.red
            importantLabel.text = "这个计划很重要!"
            remainTimeLabel.textColor = UIColor.red
        } else {
            timePlanLabel.textColor = UIColor.black
            importantLabel.textColor = UIColor.darkGray
            importantLabel.text = "合理规划并管理你的生活"
            remainTimeLabel.textColor = UIColor.darkGray
        }
        if item.shouldRemind == true {
            remainTimeLabel.text = "\(formatter.string(from: item.dueDate)) 前完成"
        } else {
            remainTimeLabel.text = "未设定提醒时间"
        }
        if item.charge {
            finishMarkLabel.text = "我已搞定"
        } else {
            finishMarkLabel.text = ""
        }

        // Configure the cell...

        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) { //解决空白页错位,在计划类别列表有同样的问题,暂时未解
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "哦...", message: "在这里你不能通过点击来改变计划的状态", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func sortDetailLists() { //按照修改时间排序
        detailLists.sort(by: { detailList1, detailList2 in
            return detailList1.nowDate.compare(detailList2.nowDate) == .orderedAscending })
    }
    
    func documentsDirectory() -> URL { //获取沙盒文件夹路径
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL { //获取数据文件地址
        print(documentsDirectory().appendingPathComponent("Checklists.plist"))
        return documentsDirectory().appendingPathComponent("Checklists.plist")
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
        }
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
    
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyPage.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "这里的计划为你按照计划的创建时间整理"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "你可以按照时间先后浏览你的计划\n在这里你无法新建计划"
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

}
