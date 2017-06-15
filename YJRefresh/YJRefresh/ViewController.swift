//
//  ViewController.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        YJNet.request(router: .login("18910402142", "kkk111"), completion: { (response: YJResponse<YJModel>) in
            
            switch response.code {
            case .success:
                print("success")
            default:
                print("fail")
            }
        })
    }


}

