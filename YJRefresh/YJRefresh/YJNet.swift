//
//  YJNet.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/15.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import Alamofire
import HandyJSON

public enum YJStatusCode: Int {
    case unknown
    case success
    case fail
    case noNet
}

fileprivate struct YJOriginalResponse: YJModelable {
    var data: Any?
    var msgs: String?
    var status: Int = 0
    var other: [String: Any]?
}

public class YJMapping {
    public var data: String?
    public var datas: String?
}

public class YJResponse<M: YJModelable> {
    
    public var data: M?
    public var datas: [M?]?
    public var code: YJStatusCode = .unknown
    public var msg: String?
    
    public var yj_mapping: YJMapping?
}

public class YJNet {
    public class func request<M: YJModelable>(router: YJRouter, configMap: ((YJMapping)->Void)? = nil, completion: ((YJResponse<M>)->Void)?) {
        
        Alamofire.request(router).responseJSON(queue: DispatchQueue.global(), options: []) { (response: DataResponse<Any>) in
            let r = YJResponse<M>()
            
            if response.result.isSuccess {
                r.yj_mapping = YJMapping()
                configMap?(r.yj_mapping!)
                successDeal(r, response: response)
            } else {
                failDeal(r)
            }
            DispatchQueue.main.async {
                completion?(r)
            }
        }
    }
}

extension YJNet {
    
    fileprivate class func successDeal<M: YJModelable>(_ r: YJResponse<M>, response: DataResponse<Any>) {
        if let originalResponse = YJOriginalResponse.deserialize(from: response.value as? NSDictionary) {
            generateData(r, data: originalResponse.data)
            generateMsg(r, msg: originalResponse.msgs)
            generateCode(r, code: originalResponse.status)
        } else {
            failDeal(r, code: 500, msg: "服务器返回数据有误")
        }
    }
    
    fileprivate class func failDeal<M: YJModelable>(_ r: YJResponse<M>, code: Int = 500, msg: String = "网络错误") {
        generateMsg(r, msg: msg)
        generateCode(r, code: code)
    }
    
    fileprivate class func generateData<M: YJModelable>(_ r: YJResponse<M>, data: Any?) {
        
        var dataDic = data as? NSDictionary
        if let dataPath = r.yj_mapping?.data {
            dataDic = dataDic?.value(forKeyPath: dataPath) as? NSDictionary
        }
        r.data = M.deserialize(from: dataDic)
        
        var dataArr = data as? [NSDictionary]
        if let datasPath = r.yj_mapping?.datas {
            dataArr = (data as? NSDictionary)?.value(forKeyPath: datasPath) as? [NSDictionary]
        }
        r.datas = dataArr?.flatMap{
            return M.deserialize(from: $0)
        }
    }
    
    fileprivate class func generateMsg<M: YJModelable>(_ r: YJResponse<M>, msg: String?) {
        r.msg = msg
    }
    
    fileprivate class func generateCode<M: YJModelable>(_ r: YJResponse<M>, code: Int) {
        
        switch code {
        case 0:
            r.code = .success
        case 500, 1:
            r.code = .fail
        case -1:
            r.code = .noNet
        default:
            r.code = .unknown
        }
    }
}
