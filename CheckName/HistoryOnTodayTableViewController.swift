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
import Kingfisher
import SafariServices

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
        if history[indexPath.row].img == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            let titleLabel = cell.viewWithTag(5212) as! UILabel
            let dateLabel = cell.viewWithTag(5211) as! UILabel
            titleLabel.text = history[indexPath.row].title
            dateLabel.text = history[indexPath.row].year + "年" + String(history[indexPath.row].month) + "月" + String(history[indexPath.row].day) +  "日"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellWithImg", for: indexPath)
            let historyImg = cell.viewWithTag(5233) as! UIImageView
            let titleLabel = cell.viewWithTag(5232) as! UILabel
            let dateLabel = cell.viewWithTag(5231) as! UILabel
            titleLabel.text = history[indexPath.row].title
            dateLabel.text = history[indexPath.row].year + "年" + String(history[indexPath.row].month) + "月" + String(history[indexPath.row].day) +  "日"
            let imgURL = URL(string: history[indexPath.row].img)
            historyImg.kf.setImage(with: imgURL)
            historyImg.layer.cornerRadius = 10
            historyImg.layer.masksToBounds = true
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let urlString = "https://www.baidu.com/ssid=d9e9494d4f4b5346944d/from=844b/s?word=\(history[indexPath.row].title)&sa=tb&ts=3926210&t_kt=0&ie=utf-8&rsv_t=42a3Z9RyeTlucF2F5DEpQWtXI%252BXOVBR2fQjw3v7Z6ZbcNQ4lWvMBXahw2w&ms=1&rsv_pq=13297195502382807656&ss=100&t_it=1&rqlang=zh&rsv_sug4=1083&inputT=174&oq=66"
        let newURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) //URL中的中文和其它特殊字符需要进行转码,否则URL返回一个nil
        let cellURL = URL(string: newURLString!)
        print("cellURL: \(cellURL!)")
        let safariVC = SFSafariViewController(url: cellURL!)
        self.show(safariVC, sender: nil)
        
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
                    if (list[i]["img"].null != nil) {
                        historyData.img = ""
                    } else {
                        historyData.img = list[i]["img"].string!
                    }
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
