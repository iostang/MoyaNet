//
//  BaseResponse.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya

class BaseResponse<T>: ResponseProtocol where T: ModelProtocol {
    
    var responseModel: ModelProtocol?
    var requestModel: RequestProtocol?
    var responseDict: NSDictionary?
    var moyaResponse: Response?
    
    var data: T?
    
    required init(requestModel: RequestProtocol, responseDict: NSDictionary?, moyaResponse: Response?) {
        self.responseDict = responseDict
        self.requestModel = requestModel
        self.moyaResponse = moyaResponse
        self.data = T.deserialize(from: responseDict)
        self.responseModel = data
    }
}

extension BaseResponse : ResponseErrorProtocol {

    func handleStatusCode(error: MoyaError) {
        switch error.errorCode {
        case 401:
            //可以做一些操作 比如 弹出登录界面
            break
        default:
            break
        }
    }
    
    /// 检测error
    func checkError(failureClosure: Failure?) -> Bool {
        
        if (self.requestModel?.ignoreError ?? false) {
            return false
        }

        
        if let isStandard = requestModel?.isStandard, isStandard {
            
            if checkErrorCode(responseDict) {
                DispatchQueue.main.safeAsync {
                    
                    if let resp = self.moyaResponse {
                        let error = MoyaError.imageMapping(resp)
                        failureClosure?(error)
                    }
                }
                return true
            }
        }
        
        return false
    }

    
    private func checkErrorCode(_ responseDict: NSDictionary?) -> Bool {
        var code: String?
        let responseCode = responseDict?["code"]
        if let c = responseCode as? Int {
            code = "\(c)"
        } else if let c = responseCode as? String {
            code = c
        }
        
        /// 校验code code有值且!=0则视为失败
        if let c = code, c != "", c != "0" {
            return true
        }
        
        return false
    }
}






