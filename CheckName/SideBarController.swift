//
//  SideBarController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/3/28.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

var ifPostMark = 0 //是否发送通知标识,0为发送,1为不发送,全局变量

class SideBarController: UITableViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var quickLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var importantLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var achivementLabel: UILabel!
    
    var city = ""
    var weather = ""
    var tem = ""
    
    // 引导页对象
    var helpItems = [KSGuideItem]()
    
    var dataTask: URLSessionTask?
    var searchResult: [String: Any]!
    
    // 定位成功通知
    let successGetLocation = Notification.Name(rawValue: "getLocationSuccess")
    
    var location: CLLocation? //用来保存获取到的地址位置信息(地理位置有可能获取不到,也有可能正在获取,此时就是nil,所以为可选值)
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var lastLocationError: Error?
    
    var timer: Timer?
    
    // 地址用于反向编码
    let geocoder = CLGeocoder() // CLGeocoder是将执行地理编码的对象
    var placemark: CLPlacemark? // CLPlacemark是包含地址结果的对象
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?

    // MARK: - CLLocationManagerDelegate中的方法
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue { //如果是未知原因导致无法定位但系统仍在努力定位则什么也不做
            return
        }
        
        lastLocationError = error
        stopLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        print("地理位置: \(lastLocation)")
        
        if lastLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if lastLocation.horizontalAccuracy < 0 {
            return
        }
        
        if self.location == nil || self.location!.horizontalAccuracy > lastLocation.horizontalAccuracy { // 这里有问题!!!!!!!!!!!!!!!!!!!!!!!!!
            
            self.location = lastLocation
            lastLocationError = nil //得到位置数据则不抛出错误
            if lastLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("定位精度已经符合要求,可以结束定位!\n")
                stopLocation()
                if ifPostMark == 0 { //发送通知
                    NotificationCenter.default.post(name: self.successGetLocation, object: nil)
                } else {
                    //什么也不做
                }
                ifPostMark = 1
            }
        }
    }
    
    func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false) // 设置了一个定时器
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if let timer = timer { // 如果15秒内找到了确定的位置则撤销计时器
            timer.invalidate()
        }
    }
    
    func didTimeOut() {
        print("请求超时")
        if location == nil { // domain是一个错误域，由一个字符串构成，这里我们自定义了一个错误域，之前用过CoreLocation的错误域kCLErrorDomain
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            stopLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionHeaderHeight = 28
        
        let setButton = UIButton(frame: CGRect(x: 180, y: UIScreen.main.bounds.maxY - 97, width: 60, height: 60))
        setButton.setBackgroundImage(UIImage(named: "设置"), for: .normal)
        setButton.addTarget(self, action: #selector(touchSet), for: .touchUpInside)
        self.tableView.addSubview(setButton)
        
        /***
        ****手动约束存在问题,待解决****
        ****
        ****
        /// 手动为setButton设置约束
        // 使用AutoLayout约束,禁止将AutoresizingMask转换为约束
        setButton.translatesAutoresizingMaskIntoConstraints = false
        // 左侧约束和下方约束
        let constraintFromLeft = NSLayoutConstraint(item: setButton, attribute: .left, relatedBy: .equal, toItem: self.tableView, attribute: .left, multiplier: 1.0, constant: 180)
        self.tableView.addConstraint(constraintFromLeft)
        let constrainFromBottom = NSLayoutConstraint(item: setButton, attribute: .bottom, relatedBy: .equal, toItem: self.tableView, attribute: .bottom, multiplier: 1.0, constant: 300)
        self.tableView.addConstraint(constrainFromBottom)
        // 宽高约束
        let constraintForWidth = NSLayoutConstraint(item: setButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 60)
        setButton.addConstraint(constraintForWidth)
        let constraintForHeight = NSLayoutConstraint(item: setButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 60)
        setButton.addConstraint(constraintForHeight)
        print("SetButton位置: \(setButton.frame)")
        ****
        ****
        ****手动约束存在问题,待解决****
        ***/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getLocation()
        self.dataTask?.cancel()
        
        NotificationCenter.default.addObserver(forName: successGetLocation, object: nil, queue: OperationQueue.main) { (Notification) in
            
            let url: URL
            if self.location == nil {
                url = URL(string: "https://error")!
            } else {
                url = URL(string: "https://api.seniverse.com/v3/weather/now.json?key=md5qkak6jj0czqxa&location=\(self.location!.coordinate.latitude):\(self.location!.coordinate.longitude)&language=zh-Hans&unit=c")!
                print("URL: \(url)")
            }
            let session = URLSession.shared
            self.dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if error != nil { // 网络发生任何错误
                    print("天气API获取错误: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.weatherLabel.text = "你的每一次努力都不应该被辜负"
                    }
                    return
                } else {
                    self.searchResult = self.parse(json: data!)
                    
                    print("搜索结果: \(self.searchResult)")
                    let json = JSON.init(self.searchResult)
                    print(json)
                    if (json["results"].null != nil) { //如果API返回异常值则天气Label不变(比如每小时次数用完)
                        DispatchQueue.main.async {
                            self.weatherLabel.text = "你的每一次努力都不应该被辜负"
                        }
                    } else {
                        self.city = json["results"][0]["location"]["name"].string!
                        self.weather = json["results"][0]["now"]["text"].string!
                        self.tem = json["results"][0]["now"]["temperature"].string!
                        DispatchQueue.main.async {
                            self.weatherLabel.text = "今日天气:" + "  " +  self.city + "  " + self.weather + "  " + self.tem + "  " + "℃"
                        }
                    }
                }
                
            })
            self.dataTask?.resume()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showHelp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.location = nil // 临时解决办法
        stopLocation()
        dataTask?.cancel()
        
        //删除观察者
        NotificationCenter.default.removeObserver(self, name: successGetLocation, object: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return "My Plan"
        } else {
            return "Bingo"
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 标签视图
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 18, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        // label.text = self.tableView（tableView，titleForHeaderInSection：section）此行代码和上面的那行功能相同
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        
        // 分隔线视图
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        // 容器视图
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(red: 104/255, green: 104/255, blue: 104/255, alpha: 1.0)
        view.addSubview(label)
        view.addSubview(separator)
        
        return view
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parse(json data: Data) -> [String: Any]? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] // 使用JSONSerialization对象将json数据转换为字典数据
        } catch {
            print("json错误:\(error)")
            return nil
        }
    }
    
    // 点击设置
    func touchSet() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let setNavigation = storyboard.instantiateViewController(withIdentifier: "Set") as! UINavigationController
        self.present(setNavigation, animated: true, completion: nil)
    }
    
    // 展示引导页
    func showHelp() {
///        Reset to show everytime.
///        KSGuideDataManager.reset(for: "SideBarGuide")
        
        let weatherItem = KSGuideItem(sourceView: weatherLabel, text: "这是你所在城市的天气,第一次查看需要获取网络和定位权限才能正常显示哟~")
        helpItems.append(weatherItem)
        let typeItem = KSGuideItem(sourceView: typeLabel, text: "这是计划类别,点击就可以进入到应用主页~")
        helpItems.append(typeItem)
        let quickItem = KSGuideItem(sourceView: quickLabel, text: "快速计划不需要创建类别,可以直接新建一个计划~")
        helpItems.append(quickItem)
        let timeItem = KSGuideItem(sourceView: timeLabel, text: "这里将你的所有计划按照时间排序~")
        helpItems.append(timeItem)
        let importantItem = KSGuideItem(sourceView: importantLabel, text: "这里是你所有标记为重要的计划~")
        helpItems.append(importantItem)
        let historyItem = KSGuideItem(sourceView: historyLabel, text: "回顾历史的长河,历史是生活的一面镜子;历史上的每一天,都是喜忧参半,历史是不能忘记的,历史上的今天,看看都发生了什么重大事件~")
        helpItems.append(historyItem)
        let achivementItem = KSGuideItem(sourceView: achivementLabel, text: "你获得的成就会显示在这里~")
        helpItems.append(achivementItem)
        let vc = KSGuideController(items: helpItems, key: "SideBarGuide")
        vc.setIndexChangeBlock { (index, item) in
            print("Index has change to \(index)")
        }
        vc.show(from: self) {
            print("Guide controller has been dismissed")
        }
    }
}
