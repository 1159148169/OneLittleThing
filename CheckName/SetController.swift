//
//  SetController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/6/22.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class SetController: UITableViewController {
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let cell = tableView.viewWithTag(9191) as! UITableViewCell!
        let feedNumLabel = cell?.viewWithTag(6800) as! UILabel!
        LCUserFeedbackAgent.sharedInstance().countUnreadFeedbackThreads({(_ number: Int, _ error: Error?) -> Void in
            if error != nil {
                // 网络出错了,不设置提醒
                feedNumLabel?.text = "没有未读消息"
            }
            else {
                // 根据未读数number,设置消息,提醒用户
                if number == 0 {
                    feedNumLabel?.text = "没有未读消息"
                } else {
                    feedNumLabel?.text = "您有\(number)条未读消息"
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // 调用LeanCloud的反馈组件
            let agent = LCUserFeedbackAgent.sharedInstance()
            agent?.showConversations(self, title: nil, contact: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
