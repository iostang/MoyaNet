//
//  UserNetwork.swift
//  Net
//
//  Created by TangChi on 2018/1/22.
//  Copyright © 2018年 TangChi. All rights reserved.
//

import UIKit
import Moya


let provider = MoyaProvider<GitHubRequest>()

class UserNetwork: BaseNetwork {
    
    class func github(failure: @escaping Failure, success: @escaping ((NSDictionary?) -> Void)) {
        print("发送网络")
        let api = GitHubRequest()
        
        provider.request(api) { (result) in
            print("done")
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response) :
                print(response)
            }
        }
        
    }
    
    class func test(failure: @escaping Failure, success: @escaping ((UserInfoModel?) -> Void)) {
        let api = BaseRequest.create(path: "/api/v3/path", method: .put)
        
        api.timeOut = 10
        
        //mock
        api.isStub = true
        api.sampleCode = 200 
        api.sampleData = api.testSampleData(fileName: "user_info")
        
        
        Net.request(api).finish {
            print("finish")
        }.failure { (error) in
            failure(error)
        }.send {(response: BaseResponse<UserInfoResponse>) in
            success(response.data?.data)
        }
    }
    
}
