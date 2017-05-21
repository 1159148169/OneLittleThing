//
//  ParallaxTableViewCell.swift
//  CheckName
//
//  Created by Shi Feng on 2017/5/9.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class ParallaxTableViewCell: UITableViewCell {

    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgBackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgBackBottomConstraint: NSLayoutConstraint!
    
    let imageParallaxFactor: CGFloat = 20
    
    var imgBackTopInitial: CGFloat!
    var imgBackBottomInitial: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.imgBackBottomConstraint.constant -= 2 * imageParallaxFactor
        self.imgBackTopInitial = self.imgBackTopConstraint.constant
        self.imgBackBottomInitial = self.imgBackBottomConstraint.constant
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBackgroundOffset(_ offset:CGFloat) {
        let boundOffset = max(0, min(1, offset))
        let pixelOffset = (1-boundOffset)*2*imageParallaxFactor
        self.imgBackTopConstraint.constant = self.imgBackTopInitial - pixelOffset
        self.imgBackBottomConstraint.constant = self.imgBackBottomInitial + pixelOffset
    }

}
