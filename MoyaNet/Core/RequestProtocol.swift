//
//  RequestProtocol.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya
import Alamofire

public enum RequestType {
    case http
    case https
    case httpsBoth([String : ServerTrustPolicy])
}

public protocol RequestProtocol: TargetType {
    
    /// 是否是标准的JSON eg: {code='',msg='',data=''}
    var isStandard: Bool { set get }
    
    /// 是有使用JSONEncoding（默认是URLEncoding）
    var isJSONEncoding: Bool { set get }
    
    /// 是否需要重试(待开发。。。)
    var retry: Bool { set get }
    
    /// 最大重试次数(待开发。。。)
    var maxAttemptCount: Int { set get }
    
    /// 忽略校验error status
    var ignoreError: Bool { set get }
    
    /// 请求超时时间
    var timeOut: TimeInterval { set get }
    
    /// 设置请求类型 单向https 双向https 默认http
    var requestType: RequestType { set get }
    
    /// 设置是否需要打桩
    var isStub: Bool { set get }
    
    /// 设置网络请求返回的code 配合isStub使用
    /// 默认200 可自定义 比如404 503 401 ...
    var sampleCode: Int { set get }
}
