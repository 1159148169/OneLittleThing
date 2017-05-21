//
//  NewTypeListTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2016/11/16.
//  Copyright © 2016年 Shi Feng. All rights reserved.
//

import UIKit

protocol AddNewListTypeDelegate: class {
    func touchChooseTypeList(_ controller: NewTypeListTableViewController, didFinishingAdding type: TypeListItem)
}

class NewTypeListTableViewController: UITableViewController {
    
    var lists:[TypeListItem]
    
    weak var delegate:AddNewListTypeDelegate?
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDcoder: NSCoder) {
        lists = [TypeListItem]()
        let item0 = TypeListItem(name: "学习") //必须自己定义一个构造器
        item0.typeDetail = "I Love Study!"
        item0.typeImage = UIImage(named: "study.jpg")!
        item0.typeImageView = UIImageView(image: item0.typeImage)
        lists.append(item0)
        
        let item1 = TypeListItem(name: "运动")
        item1.typeDetail = "I Love Sports!"
        item1.typeImage = UIImage(named: "sports.jpg")!
        item1.typeImageView = UIImageView(image: item1.typeImage)
        lists.append(item1)
        
        let item2 = TypeListItem(name: "工作")
        item2.typeDetail = "I Love Works!"
        item2.typeImage = UIImage(named: "work.jpg")!
        item2.typeImageView = UIImageView(image: item2.typeImage)
        lists.append(item2)
        
        let item3 = TypeListItem(name: "生活")
        item3.typeDetail = "I Love Life!"
        item3.typeImage = UIImage(named: "life.jpg")!
        item3.typeImageView = UIImageView(image: item3.typeImage)
        lists.append(item3)
        
        let item4 = TypeListItem(name: "购物")
        item4.typeDetail = "I Love Buy!"
        item4.typeImage = UIImage(named: "shopping.jpg")!
        item4.typeImageView = UIImageView(image: item4.typeImage)
        lists.append(item4)
        
        let item5 = TypeListItem(name: "商业")
        item5.typeDetail = "I Love Business!"
        item5.typeImage = UIImage(named: "business.jpg")!
        item5.typeImageView = UIImageView(image: item5.typeImage)
        lists.append(item5)
        
        let item6 = TypeListItem(name: "学校")
        item6.typeDetail = "I Love School!"
        item6.typeImage = UIImage(named: "school.jpg")!
        item6.typeImageView = UIImageView(image: item6.typeImage)
        lists.append(item6)
        
        let item7 = TypeListItem(name: "公司")
        item7.typeDetail = "I Love Company!"
        item7.typeImage = UIImage(named: "company.jpg")!
        item7.typeImageView = UIImageView(image: item7.typeImage)
        lists.append(item7)
        
        let item8 = TypeListItem(name: "其他")
        item8.typeDetail = "Interesting!"
        item8.typeImage = UIImage(named: "others.jpg")!
        item8.typeImageView = UIImageView(image: item8.typeImage)
        lists.append(item8)
        
        super.init(coder: aDcoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 100
        self.tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none //去除cell之间的分割线
        
        self.tableView.reloadData()
        self.tableView.animateTableView(animation: .top(duration: 1), completion: nil)

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
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTypeCell", for: indexPath) as! ParallaxTableViewCell

        let typeLabel = cell.viewWithTag(100) as! UILabel
        let typeDetailLabel = cell.viewWithTag(101) as! UILabel
        
        let typeName = lists[indexPath.row]
        
        typeLabel.text = typeName.name
        typeDetailLabel.text = typeName.typeDetail
        
        //添加cell背景图
//        cell.backgroundView = typeName.typeImageView
        cell.imgBack.image = typeName.typeImage

        return cell
    }
    
    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTypeCell", for: indexPath)
        let typeName = lists[indexPath.row]
        
        cell.backgroundView = typeName.typeImageView
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //实现点击单元格后将单元格添加到主界面中并在此界面删除单元格
        let newType = lists[indexPath.row]
        delegate?.touchChooseTypeList(self, didFinishingAdding: newType)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.tableView) {
            for indexPath in self.tableView.indexPathsForVisibleRows! {
                self.setCellImageOffset(self.tableView.cellForRow(at: indexPath) as! ParallaxTableViewCell, indexPath: indexPath as NSIndexPath)
            }
        }
    }
    
    func setCellImageOffset(_ cell: ParallaxTableViewCell, indexPath: NSIndexPath) {
        let cellFrame = self.tableView.rectForRow(at: indexPath as IndexPath)
        let cellFrameInTable = self.tableView.convert(cellFrame, to:self.tableView.superview)
        let cellOffset = cellFrameInTable.origin.y + cellFrameInTable.size.height
        let tableHeight = self.tableView.bounds.size.height + cellFrameInTable.size.height
        let cellOffsetFactor = cellOffset / tableHeight
        cell.setBackgroundOffset(cellOffsetFactor)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageCell = cell as! ParallaxTableViewCell
        self.setCellImageOffset(imageCell, indexPath: indexPath as NSIndexPath)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
