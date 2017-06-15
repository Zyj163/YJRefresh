//
//  YJTableViewController.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit

class YJTableViewController: UIViewController, YJRefreshViewModelOwnerable {

    fileprivate let tv = UITableView()
    
    var tableView: UITableView? {
        return tv
    }
    
    lazy var viewModel: YJRefreshViewModel<YJModel, YJTableViewCell>? = YJRefreshViewModel<YJModel, YJTableViewCell>(self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    deinit {
        print("controller deinit")
    }
}

extension YJTableViewController {
    
    fileprivate func setupUI() {
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        tableView?.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            
            self?.viewModel?.refresh(0, configMap: { (mapping) in
                mapping.datas = "result"
                mapping.data = "initCustomer"
            }, { (response) in
                self?.tableView?.mj_header.endRefreshing()
                
                switch response.code {
                case .success:
                    print("success")
                default:
                    print("fail")
                }
            })
            
        })
    }
    
}
