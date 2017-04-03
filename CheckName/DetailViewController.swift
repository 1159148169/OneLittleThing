//
//  DetailViewController.swift
//  CheckName
//
//  Created by Shi Feng on 2017/4/3.
//  Copyright © 2017年 Shi Feng. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var items: NameItem!
    var typeNames: TypeListItem!
    
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var importantLabel: UILabel!
    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var finishLabel: UILabel!
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom // 此ViewController转场为自定义
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.tintColor = UIColor.black
        popView.layer.cornerRadius = 10 // 圆角
        
        if items != nil {
            updateUI()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let nowTimeFormatter = DateFormatter()
        nowTimeFormatter.dateFormat = "MM月dd日"
        
        planLabel.text = items.name
        kindLabel.text = typeNames.name
        if items.shouldImportant == true {
            importantLabel.text = "这个计划很重要!"
        } else {
            importantLabel.text = "这是一个日常计划"
        }
        if items.shouldRemind == true {
            remindLabel.text = formatter.string(from: items.dueDate)
        } else {
            remindLabel.text = "该计划未设定提醒"
        }
        updateTimeLabel.text = nowTimeFormatter.string(from: items.nowDate)
        if items.charge == true {
            finishLabel.text = "该计划已完成"
        } else {
            finishLabel.text = "该计划未完成"
        }
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting) // 不使用标准转场，使用自定义的转场
    }
}
