//
//  ResponseProtocol.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya

public protocol ResponseProtocol {
    var responseModel: ModelProtocol? { set get }
    var requestModel: RequestProtocol? { set get }
    var responseDict: NSDictionary? { set get }
    var moyaResponse: Response? { set get }
    init(requestModel: RequestProtocol, responseDict: NSDictionary?, moyaResponse: Response?)
}
