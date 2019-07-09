//
//  FTUserInfoModel.swift
//  Net
//
//  Created by TangChi on 2018/1/22.
//  Copyright © 2018年 TangChi. All rights reserved.
//

import UIKit
import HandyJSON

class BaseModel: ModelProtocol {
    
    required public init() { }
    
    public func mapping(mapper: HelpingMapper) {
        
    }
}

class BaseNetModel: BaseModel {
    var msg: String?
    var code: String?
    var status: String?
}

class UserInfoResponse: BaseNetModel {
    var data: UserInfoModel?
}

class UserInfoModel: BaseNetModel {
    var nickname: String?
    var user_id: String?
    var login_string: String?
    var registedDate: String?
    var avatar_path: String?
    var deviceVersion: String?
    var cellphone: String?
    var created_at: String?
}
