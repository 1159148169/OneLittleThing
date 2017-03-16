//
//  TypeTableViewCell.swift
//  CheckName
//
//  Created by Shi Feng on 2017/1/16.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class TypeTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var typeAccessoryButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
