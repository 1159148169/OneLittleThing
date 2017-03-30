//
//  HudView.swift
//  CheckName
//
//  Created by Shi Feng on 2017/3/29.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect( x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
      
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint( x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            image.draw(at: imagePoint)
        }
        
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white ]
        
        let textSize = text.size(attributes: attribs)
        
        let textPoint = CGPoint( x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: attribs)
        
    }
    
    // HUD动画
    // HUD视图将迅速淡入，因为其不透明度从完全透明到完全不透明，它将从原始尺寸的1.3倍缩小到其常规宽度和高度
    func show(animated: Bool) {
        if animated {
            alpha = 0 // 视图完全透明
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3) // 缩放因子1.3
            
            /*
             简单动画的实现
             UIView.animate(withDuration: 0.3, animations: {
             self.alpha = 1 // 视图完全不透明
             self.transform = CGAffineTransform.identity // 视图比例大小恢复
             })
             */
            
            // Spring动画的实现，对比上面简单动画的实现
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
            
        }
    }
}
