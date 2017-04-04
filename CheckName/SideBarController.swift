//
//  SideBarController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/3/28.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit
import CoreLocation

class SideBarController: UITableViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    var dataTask: URLSessionTask?
    var totalWetherString: String?
    var searchResult: [String: String]!
    var locationString: String = "error"
    
    
    var location: CLLocation? //用来保存获取到的地址位置信息(地理位置有可能获取不到,也有可能正在获取,此时就是nil,所以为可选值)
    var updatingLocation = false
    var lastLocationError: Error?
    
    var timer: Timer?
    
    // 地址用于反向编码
    let geocoder = CLGeocoder() // CLGeocoder是将执行地理编码的对象
    var placemark: CLPlacemark? // CLPlacemark是包含地址结果的对象
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    let locationManager = CLLocationManager()
    

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
                
            }
            if !performingReverseGeocoding {
                print("Going to geocode!")
                
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(lastLocation, completionHandler: {
                    placemarks, error in //闭包里的代码不会马上执行，闭包保留以供以后由CLGeocoder对象使用，并且只有在CLGeocoder找到地址或遇到错误后才执行
                    
                    print("Found Placemarks \(String(describing: placemarks)) error \(String(describing: error))")
                    
                    self.lastGeocodingError = error
                    if error == nil,let p = placemarks,!p.isEmpty { // 这样的写法表示placemarks是可选值，需要解包再使用，!p.isEmpty表示如果placemarks数组不为空，就应该只输入此if语句，这句可以这么理解：如果没有错误，并且解包的地标数组不为空
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    
                    self.location = nil // 临时解决办法
                    
                    print("详细地址: \(self.placemark!.administrativeArea!)")
                    
                    if self.placemark!.administrativeArea != nil {
                        self.locationString = self.convertAdtressString(with: self.placemark!.administrativeArea!)
                    } else {
                        self.locationString = "error"
                    }
                    
                })
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
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false) // 设置了一个定时器
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if let timer = timer { // 如果60秒内找到了确定的位置或用户点击了停止按钮，则撤销计时器
            timer.invalidate()
        }
    }
    
    func didTimeOut() {
        print("请求超时")
        
        if location == nil { // domain是一个错误域，由一个字符串构成，这里我们自定义了一个错误域，之前用过CoreLocation的错误域kCLErrorDomain
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil) // 这里的错误类型决定了屏幕信息的更新状态
        }
        
    }
    
    
    func string(from placemark: CLPlacemark) -> String {
        var line2 = ""
        if let s = placemark.locality { //地区
            line2 += s + ""
        }
        if let s = placemark.administrativeArea { // 行政区域
            line2 += s + ""
        }
        if let s = placemark.postalCode { // 邮政编码
            line2 += s
        }
        
        return line2
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getLocation()
        
        let delayInSeconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: { // 暂时只能使用延迟执行使定位先于网络请求执行
            
            self.dataTask?.cancel()
            let url: URL
            if self.locationString == "error" {
                url = URL(string: "https://error")!
            } else {
                url = URL(string: "https://chat.crazyc.cn/weather/" + "\(self.locationString)")!
            }
            print("locationString: \(self.locationString)")
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
                    print(self.searchResult!["today_situation"]!)
                    
                    DispatchQueue.main.async {
                        self.weatherLabel.text = "今日天气:" + "  " +  self.searchResult["today_temperature"]! + "  " + self.searchResult["today_situation"]!
                    }
                }
                
            })
            self.dataTask?.resume()
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        stopLocation()
        dataTask?.cancel()
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let superNameController = storyboard.instantiateViewController(withIdentifier: "MainTabelViewController") as! SuperNameTableViewController
//        let cell = superNameController.tableView.dequeueReusableCell(withIdentifier: "SuperNameListCell") as! TypeTableViewCell
//        
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let superNameController = storyboard.instantiateViewController(withIdentifier: "MainTabelViewController") as! SuperNameTableViewController
//        let cell = superNameController.tableView.dequeueReusableCell(withIdentifier: "SuperNameListCell") as! TypeTableViewCell
//        
//    }
    
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
    
    func convertAdtressString(with adress: String) -> String {
        switch adress {
        case "重庆市":
            return "chongqing"
        case "北京市":
            return "beijing"
        case "上海市":
            return "shanghai"
        case "天津市":
            return "tianjin"
        case "广州市":
            return "guangzhou"
        case "深圳市":
            return "shenzhen"
        case "杭州市":
            return "hangzhou"
        case "呼和浩特市":
            return "huhehaote"
        case "乌兰察布市":
            return "wulanchabu"
        case "桂林市":
            return "guilin"
        case "包头市":
            return "baotou"
        case "大连市":
            return "dalian"
        case "成都市":
            return "chengdu"
        case "吉林市":
            return "jilin"
        default:
            return "error"
        }
    }
}
