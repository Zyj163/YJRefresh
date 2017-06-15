//
//  YYJRefreshViewModel.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import HandyJSON

protocol YJRefreshViewModelOwnerable: class {
    var tableView: UITableView? {get}
    var collectionView: UICollectionView? {get}
}

extension YJRefreshViewModelOwnerable where Self: UIViewController {
    var tableView: UITableView? {return nil}
    var collectionView: UICollectionView? {return nil}
}

protocol YJCellable {
    associatedtype ModelClass
    var model: ModelClass? {get set}
    
    var reuseIdentifier: String? {get}
}

protocol YJModelable: HandyJSON {
    
}

class YJRefreshViewModel<M: YJModelable, C: UIView>: NSObject, UITableViewDataSource, UICollectionViewDataSource where C: YJCellable, C.ModelClass == M {
    
    fileprivate let identify = "YJCell"
    
    fileprivate weak var owner: YJRefreshViewModelOwnerable!
    
    fileprivate var datas: [M?] = [M?]()
    
    fileprivate override init() {
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath) as! C
        cell.model = datas[indexPath.row]
        
        return cell as! UITableViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! C
        cell.model = datas[indexPath.row]
        
        return cell as! UICollectionViewCell
    }
    
    deinit {
        print("viewmodel deinit")
    }
}

extension YJRefreshViewModel {
    convenience init<T: UIViewController>(_ owner: T) where T: YJRefreshViewModelOwnerable {
        self.init()
        
        self.owner = owner
        
        owner.tableView?.dataSource = self
        owner.tableView?.register(C.self, forCellReuseIdentifier: identify)
        
        owner.collectionView?.dataSource = self
        owner.collectionView?.register(C.self, forCellWithReuseIdentifier: identify)
    }
    
    func refresh(_ start: Int = 0, configMap: ((YJMapping)->Void)? = nil, _ completion: ((YJResponse<M>)->())? = nil) {
    
        YJNet.request(router: .main(10), configMap: configMap, completion: { (response: YJResponse<M>) in
            
            switch response.code {
                
            case .success:
                if let datas = response.datas {
                    if start == 0 {
                        self.datas.removeAll()
                    }
                    self.datas.append(contentsOf: datas)
                    self.owner.tableView?.reloadData()
                    self.owner.collectionView?.reloadData()
                }
                
            default:
                break
            }
            
            completion?(response)
        })
        
    }
}



