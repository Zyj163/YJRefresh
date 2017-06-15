//
//  YJRouter.swift
//  YJRefresh
//
//  Created by 张永俊 on 2017/6/15.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import Alamofire

//MARK: outer
enum YJRouter {
    static let baseURLString = "http://10.0.0.19:8080"
    
    case login(String, String)
    case addressList(Int)
    case main(Int)
}

//MARK: request
extension YJRouter: URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        let url = try YJRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return try encoding.encode(urlRequest, with: parameters)
    }
}

//MARK: encoding
extension YJRouter {
    var encoding: ParameterEncoding {
        switch self {
        case .addressList, .login, .main:
            return URLEncoding.default
        }
    }
}

//MARK: method
extension YJRouter {
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }
}

//MARK: path
extension YJRouter {
    var path: String {
        switch self {
        case .login:
            return "app/login/send"
        case .addressList:
            return "app/customer/address/all"
        case .main:
            return "app/customer/searchInfoHistory"
        }
    }
}

//MARK: parameters
extension YJRouter {
    var parameters: Parameters? {
        switch self {
        case let .login(username, password):
            return ["username": username, "password": password]
        case let .addressList(pageSize), let .main(pageSize):
            return ["pageNumber": pageSize]
        }
    }
}


