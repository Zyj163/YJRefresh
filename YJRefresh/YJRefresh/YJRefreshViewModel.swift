//
//  YYJRefreshViewModel.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/14.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import HandyJSON

public protocol YJRefreshViewModelOwnerable: class {
    var tableView: UITableView? {get}
    var collectionView: UICollectionView? {get}
}

extension YJRefreshViewModelOwnerable where Self: UIViewController {
    var tableView: UITableView? {return nil}
    var collectionView: UICollectionView? {return nil}
}

public protocol YJCellable {
    associatedtype ModelClass
    var model: ModelClass? {get set}
    
    var reuseIdentifier: String? {get}
}

public protocol YJModelable: HandyJSON {
    
}

public enum YJRefreshRowType {
    case row
    case section
}

public class YJRefreshViewModel<M: YJModelable, C: UIView>: NSObject, UITableViewDataSource, UICollectionViewDataSource where C: YJCellable, C.ModelClass == M {
    
    fileprivate let identify = "YJCell"
    
    fileprivate weak var owner: YJRefreshViewModelOwnerable!
    
    fileprivate var datas: [M?] = [M?]()
    
    fileprivate override init() {
        super.init()
    }
    
    public var refreshType: YJRefreshRowType = .row
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return refreshType == .row ? 1 : datas.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refreshType == .section ? 1 : datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath) as! C
        cell.model = datas[indexPath.row]
        
        return cell as! UITableViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! C
        cell.model = datas[indexPath.row]
        
        return cell as! UICollectionViewCell
    }
    
    deinit {
        print("viewmodel deinit")
    }
}

extension YJRefreshViewModel {
    public convenience init<T: UIViewController>(_ owner: T, refreshType: YJRefreshRowType = .row) where T: YJRefreshViewModelOwnerable {
        self.init()
        
        self.refreshType = refreshType
        self.owner = owner
        
        owner.tableView?.dataSource = self
        owner.tableView?.register(C.self, forCellReuseIdentifier: identify)
        
        owner.collectionView?.dataSource = self
        owner.collectionView?.register(C.self, forCellWithReuseIdentifier: identify)
    }
    
    public func defalutDealWithResponse(_ start: Int = 0, response: YJResponse<M>) {
        switch response.code {
        case .success:
            if let datas = response.datas {
                if start == 0 {
                    headerRefresh(datas)
                    return
                }
                footerLoad(datas)
            }
        default:
            break
        }
    }
    
    public func headerRefresh(_ datas: [M?]) {
        self.datas.removeAll()
        self.datas.append(contentsOf: datas)
        self.owner.tableView?.reloadData()
        self.owner.collectionView?.reloadData()
    }
    
    public func footerLoad(_ datas: [M?]) {
        var indexPaths = [IndexPath]()
        for i in 0..<datas.count {
            let row = refreshType == .row ? i + datas.count - 1 : 0
            let section = refreshType == .section ? i + datas.count - 1 : 0
            let indexPath = IndexPath(row: row, section: section)
            
            indexPaths.append(indexPath)
        }
        
        let indexSet = IndexSet(integersIn: self.datas.count..<datas.count + self.datas.count)
        
        self.datas.append(contentsOf: datas)
        
        refreshType == .row ?
            self.owner.tableView?.reloadRows(at: indexPaths, with: .fade) :
            self.owner.tableView?.reloadSections(indexSet, with: .fade)
        
        refreshType == .row ?
            self.owner.collectionView?.reloadItems(at: indexPaths) :
            self.owner.collectionView?.reloadSections(indexSet)
    }
}



