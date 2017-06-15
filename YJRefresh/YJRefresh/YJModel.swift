//
//  YJModel.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

class YJModel: NSObject, YJModelable {
    var name: String?
    
    var source_name: String?
    
    override required init() {
        super.init()
    }
    
    override var description: String {
        return "name: \(String(describing: name))"
    }
}
