//
//  YJTableViewCell.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit

class YJTableViewCell: UITableViewCell, YJCellable {

    typealias ModelClass = YJModel
    
    var model: ModelClass? {
        didSet {
            textLabel?.text = model?.source_name
        }
    }

}
