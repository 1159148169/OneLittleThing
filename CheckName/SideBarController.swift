//
//  SideBarController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/3/28.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class SideBarController: UITableViewController {
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    var dataTask: URLSessionTask?
    var totalWetherString: String?
    var searchResult: [String: String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        dataTask?.cancel()
        let url = URL(string: "https://chat.crazyc.cn/weather/chongqing")!
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil { // 网络发生任何错误
                DispatchQueue.main.async {
                    self.weatherLabel.text = "你的每一次努力都不应该被辜负"
                }
                return
            } else {
                self.searchResult = self.parse(json: data!)
                
                print("搜索结果: \(self.searchResult)")
                print(self.searchResult!["today_situation"]!)
                
                DispatchQueue.main.async {
                    self.weatherLabel.text = "今日天气:" + "  " +  self.searchResult["today_temperature"]! + "  " + self.searchResult["today_situation"]!
                }
            }
            
        })
        dataTask?.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parse(json data: Data) -> [String: String]? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] // 使用JSONSerialization对象将json数据转换为字典数据
        } catch {
            print("json错误:\(error)")
            return nil
        }
    }
}
