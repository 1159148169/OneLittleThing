//
//  ImportantPlanTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/1/15.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class ImportantPlanTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lists = getTypeName()!
        var count = 0
        
        //MARK:-两层循环获取具体计划
        for _ in lists {
            for detail in lists[count].items {
                if detail.shouldImportant { //只有重要计划才添加
                    detailLists.append(detail)
                }
            }
            count += 1
        }
        self.sortDetailLists()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImportantPlanCell", for: indexPath)
        cell.accessoryType = .none
        cell.accessoryView = cell.viewWithTag(455) as! UIButton
        
        let timePlanLabel = cell.viewWithTag(450) as! UILabel
        let importantLabel = cell.viewWithTag(451) as! UILabel
        let remainTimeLabel = cell.viewWithTag(452) as! UILabel
        let finishMarkLabel = cell.viewWithTag(453) as! UILabel
        let nowTimeLabel = cell.viewWithTag(454) as! UILabel
        
        let item = detailLists[indexPath.row]
        
        
        
        // 设置计划字体及下划线格式，用作删除线
        var attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 20)];
        
        if item.charge == true {
            attributes[NSForegroundColorAttributeName] = UIColor.lightGray
            attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
        } else {
            attributes[NSForegroundColorAttributeName] = UIColor.black
        }
        timePlanLabel.attributedText = NSAttributedString(string: item.name, attributes: attributes)
        
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
            remainTimeLabel.attributedText = NSAttributedString(string: "\(formatter.string(from: item.dueDate)) 前完成", attributes: rememberAndImportantAttributes)
        } else {
            remainTimeLabel.attributedText = NSAttributedString(string: "未设定提醒时间", attributes: rememberAndImportantAttributes)
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
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let item = detailLists[indexPath.row]
            detailController.items = item
            detailController.typeNames = item.superTypeName
        }
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
    
    func sortDetailLists() { //按照修改时间排序
        detailLists.sort(by: { detailList1, detailList2 in
            return detailList1.nowDate.compare(detailList2.nowDate) == .orderedAscending })
    }
    
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyPage.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "这里的计划是你所有标记为“重要”的计划"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "你可以优先完成这里的计划\n在这里你无法新建计划"
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
