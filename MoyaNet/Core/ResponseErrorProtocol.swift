//
//  ResponseErrorProtocol.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya

public protocol ResponseErrorProtocol {
    
    // 检测errorcode status协议 FTNet内部有实现 如果Response实现这个协议就会优先处理
    func checkError(failureClosure: Failure?) -> Bool
    
    // 如果请求code > 399
    func handleStatusCode(error: MoyaError)
}
