//
//  BaseRequest.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya
import Alamofire

struct BaseConst {
    static let baseURL = "https://www.apple.com"
}

class BaseRequest {
    
    fileprivate var _baseURL: URL!
    fileprivate var _path: String = ""
    fileprivate var _method: Moya.Method = .get
    fileprivate var _parameters: [String: Any]?
    fileprivate var _parameterEncoding: ParameterEncoding = URLEncoding.default
    fileprivate var _sampleData: Data?
    fileprivate var _task: Task?
    fileprivate var _headers: HTTPHeaders?
    fileprivate var _requestType: RequestType = .http
    
    fileprivate var _isStandard: Bool = true
    fileprivate var _isJSONEncoding = false
    fileprivate var _retry: Bool = false
    fileprivate var _maxAttemptCount: Int = 0
    fileprivate var _ignoreError: Bool = false
    fileprivate var _timeOut: TimeInterval = 30
    fileprivate var _isStub: Bool = false
    fileprivate var _sampleCode: Int = 200
    
    deinit {
        print("deinit req")
    }
    
    class func create(baseURL: String = BaseConst.baseURL,
                      path: String,
                      method: Moya.Method = .get,
                      params: NetJSON? = NetJSON(),
                      parameterEncoding: ParameterEncoding = URLEncoding.default,
                      task: Task? = nil,
                      sampleData: Data? = nil,
                      headers: HTTPHeaders? = nil,
                      requestType: RequestType = BaseRequest.defaultRequestType) -> BaseRequest {
        let api = BaseRequest()
        api._baseURL = URL(string: baseURL)!
        api._method = method
        api._path = path
        api._parameters = api.ex_params(params)
        api._parameterEncoding = parameterEncoding
        api._task = task
        api._sampleData = sampleData
        api._headers = headers ?? BaseRequest.defaultHTTPHeaders()
        api._requestType = requestType
        return api
    }
    
    static func defaultHTTPHeaders() -> HTTPHeaders {
        var header: [String: String] = [:]
        header["Locale"] = "en"
        header["Network"] =  "WiFi"
        return header
    }
    
    func ex_params(_ params: NetJSON?) -> [String: Any] {

        let notNilParams = params ?? NetJSON()
        
        var dict = [String: Any]()
        
        /// 过滤optional类型参数
        notNilParams.forEach({ (k,v) in
            if let newV = v {
                dict[k] = newV
            }
        })
        
        dict["locale"] = "en"
        
        return dict
    }
    
    static let defaultRequestType: RequestType =  {
        let reqType = RequestType.https
        return reqType
    }()
    
    
    func testSampleData(fileName: String, type: String = "json") -> Data {
        guard let path = Bundle.main.path(forResource: fileName, ofType: type),
            let data = NSData(contentsOfFile: path) else {
                return Data()
        }
        self.isStub = true
        return data as Data
    }
    
    
}


extension BaseRequest: RequestProtocol {
    var isStub: Bool {
        get {
            return _isStub
        }
        set {
            _isStub = newValue
        }
    }
    
    var sampleCode: Int {
        get {
            return _sampleCode
        }
        set {
            _sampleCode = newValue
        }
    }
    
    var baseURL: URL {
        return _baseURL
    }
    
    var path: String {
        return _path
    }
    
    var method: Moya.Method {
        return _method
    }
    
    var parameterEncoding: ParameterEncoding {
        return _parameterEncoding
    }
    
    var task: Task {
        if let t = _task {
            return t
        }
        
        return .requestParameters(parameters: _parameters ?? [String: Any](), encoding: parameterEncoding)
    }
    
    var sampleData: Data {
        set {
            _sampleData = newValue
        }
        get {
            return _sampleData ?? "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)! as Data
        }
    }
    
    var headers: [String: String]? {
        return _headers
    }
    
    var isStandard: Bool {
        set {
            _isStandard = newValue
        }
        get {
            return _isStandard
        }
    }
    
    var isJSONEncoding: Bool {
        set {
            _isJSONEncoding = newValue
            if _isJSONEncoding {
                _parameterEncoding = JSONEncoding.default
                _headers?["Content-Type"] = "application/json"
            } else {
                _parameterEncoding = URLEncoding.default
                _headers?["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
            }
        }
        
        get {
            return _isJSONEncoding
        }
    }
    
    var retry: Bool {
        set {
            _retry = newValue
        }
        get {
            return _retry
        }
    }
    
    var maxAttemptCount: Int {
        set {
            _maxAttemptCount = newValue
        }
        get {
            return _maxAttemptCount
        }
    }
    
    var ignoreError: Bool {
        set {
            _ignoreError = newValue
        }
        get {
            return _ignoreError
        }
    }
    
    var timeOut: TimeInterval {
        set {
            _timeOut = newValue
        }
        get {
            return _timeOut
        }
    }
    
    var requestType: RequestType {
        set {
            _requestType = newValue
        }
        get {
            return _requestType
        }
    }
    
}
