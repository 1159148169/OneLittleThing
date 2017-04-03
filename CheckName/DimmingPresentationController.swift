//
//  DimmingPresentationController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/4/3.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false // 让之前的视图不要消失
    }
}
