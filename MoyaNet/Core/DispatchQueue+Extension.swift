//
//  DispatchQueue+Extension.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
