//
//  ViewController.swift
//  MoyaNet
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }


    func request() {
        
        UserNetwork.github(failure: {
            [weak self] (error) in
            guard let `self` = self else { return }
            let text = error.errorDescription ?? ""
            self.textView.text += text
        }, success: {
            [weak self] (response) in
            guard let `self` = self else { return }
            let text = response?.description ?? ""
            self.textView.text += text
        })
        
        UserNetwork.test(failure: {
            [weak self] (error) in
            guard let `self` = self else { return }
            let text = error.errorDescription ?? ""
            self.textView.text += text
        }, success: {
            [weak self] (data) in
            guard let `self` = self else { return }
            
            let text = "\(data?.toJSONString() ?? "")"
            
            self.textView.text += text
        })
    }
    
}

