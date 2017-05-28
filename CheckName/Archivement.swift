//
//  Archivement.swift
//  CheckName
//
//  Created by Shi Feng on 2017/5/27.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import Foundation

/// kind加上会报错,抽空看一下为啥
class Archivement: NSObject,NSCoding {
    var title: String = ""
    var subTitle: String = ""
    var picURL: String = ""
//    var kind: Int64 = 0 // kind表示成就类型:10010为新建10,10050为新建50,10100为新建100,10500为新建500,11000为新建1000;20010为完成10,20050为完成50,20100为完成100,20500为完成500,21000为完成1000
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "Title") as! String
        self.subTitle = aDecoder.decodeObject(forKey: "SubTitle") as! String
        self.picURL = aDecoder.decodeObject(forKey: "PicURL") as! String
//        self.kind = aDecoder.decodeObject(forKey: "Kind") as! Int64
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "Title")
        aCoder.encode(subTitle, forKey: "SubTitle")
        aCoder.encode(picURL, forKey: "PicURL")
//        aCoder.encode(kind, forKey: "Kind")
    }
}
