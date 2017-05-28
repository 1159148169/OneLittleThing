//
//  ArchivementTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/5/27.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class ArchivementTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var archivementArray = [Archivement]()
    var archivementDataArray = [NSData]()

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
        
        if UserDefaults.standard.array(forKey: "Archive") == nil {
            // 如果UserDefaults为空则什么也不做
        } else {
            self.archivementDataArray = UserDefaults.standard.array(forKey: "Archive") as! [NSData]
            for i in archivementDataArray {
                let archivement = NSKeyedUnarchiver.unarchiveObject(with: i as Data) as! Archivement
                archivementArray.append(archivement)
            }
        }

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
        return archivementArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchivementCell", for: indexPath)
        // Configure the cell...
        let titleLabel = cell.viewWithTag(9090) as! UILabel
        let subTitleLabel = cell.viewWithTag(9091) as! UILabel
        
        titleLabel.text = archivementArray[indexPath.row].title
        subTitleLabel.text = archivementArray[indexPath.row].subTitle

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //DZNEmptyDataSet协议中方法的实现
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "成就奖章.png")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "现在你还没有获得成就"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: UIColor.darkGray]
        return NSAttributedString(string: text, attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "去做计划吧\n相信我\n只要有坚持不懈的毅力\n你很快就会在这里找到你想要的"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(14.0)), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(17.0))]
        return NSAttributedString(string: "加油!", attributes: attributes)
        
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
