//
//  HistoryOnTodayTableViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/5/23.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HistoryOnTodayTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var history = [History]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.tableView.rowHeight = 100
        self.tableView.tableFooterView = UIView()
        
        getHistory()
        
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
        return history.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        // Configure the cell...
        let titleLabel = cell.viewWithTag(5212) as! UILabel
        let dateLabel = cell.viewWithTag(5211) as! UILabel
        titleLabel.text = history[indexPath.row].title
        dateLabel.text = history[indexPath.row].year + "年" + String(history[indexPath.row].month) + "月" + String(history[indexPath.row].day) +  "日"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getHistory() {
        self.pleaseWait()
        let parm: Parameters = [
            "showapi_appid":"38828",
            "showapi_sign":"387658006e2e41f089feeeeb74af0218"
        ]
        Alamofire.request("https://route.showapi.com/119-42", method: .get, parameters: parm).responseJSON { (response) in
            switch response.result {
            case .success(let result):
                let json = JSON.init(result)
                print(json)
                let body = json["showapi_res_body"]
                let list = body["list"]
                for i in 0 ..< list.count {
                    let historyData = History()
                    historyData.title = list[i]["title"].string!
                    historyData.month = list[i]["month"].int!
                    historyData.year = list[i]["year"].string!
                    historyData.day = list[i]["day"].int!
                    self.history.append(historyData)
                }
                self.tableView.reloadData()
                self.clearAllNotice()
                self.successNotice("加载成功", autoClear: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
