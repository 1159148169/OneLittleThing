//
//  GradientView.swift
//  CheckName
//
//  Created by Shi Feng on 2017/4/3.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    // 只需要使用init（frame）来创建GradientView实例。另一个init方法init？（coder）在这个应用程序中从未使用过。 UIView要求所有子类实现init？（coder） - 这就是为什么它被标记为必需的 - 如果你删除这个方法，Xcode会给出一个错误
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let components: [CGFloat] = [0,0,0,0.3,0,0,0,0.7]
        let locations: [CGFloat] = [0,1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
