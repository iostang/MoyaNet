//
//  Net.swift
//  Net
//
//  Created by 🥄💻 on 2019/7/9.
//  Copyright © 2019 TangChi. All rights reserved.
//

import UIKit
import Moya
import Alamofire

public typealias Success<T: ResponseProtocol> = (T) -> Void
public typealias Failure = (MoyaError) -> Void
public typealias Finish = () -> Void

public typealias NetJSON = [String : Any?]

public class Net: NSObject {
    
    private let netQueue = DispatchQueue(label: "com.ft.net")
    
    private(set) var requestApi: RequestProtocol?
    private(set) var finishClosure: Finish?
    private(set) var failureClosure: Failure?
    
    public init(req: RequestProtocol) {
        super.init()
        self.requestApi = req
    }
    
    public static func request(_ req: RequestProtocol) -> Net {
        let net = Net(req: req)
        return net
    }
    
    /// 请求成功
    public func finish(_ closure: @escaping Finish) -> Self {
        finishClosure = closure
        return self
    }
    
    /// 请求失败
    public func failure(_ closure: @escaping Failure) -> Self {
        failureClosure = closure
        return self
    }
   
    
    /// 发送请求并处理结果
    @discardableResult
    public func send<T: ResponseProtocol>(success successClosure: @escaping Success<T>) -> Cancellable? {
        
        guard let request = requestApi else { return nil }
        
        let req = MultiTarget(request)
        
        let provider = createProvider(req: request)
        
        return provider.request(req, callbackQueue: netQueue) { [weak self] (result) in
            
            guard let `self` = self else {
                return
            }
            
            if let f = self.finishClosure {
                DispatchQueue.main.safeAsync {
                    f()
                }
            }
        
            switch result {
            case let .success(moyaResponse):
                self.responseSuccess(request: request,
                                     response: moyaResponse,
                                     successClosure: successClosure)
            case .failure(let error):
                self.responseFailure(error: error)
            }
        }
    }
    
    /// 处理失败
    func responseFailure(error: MoyaError) {
        DispatchQueue.main.safeAsync {
            if let f = self.failureClosure {
                let e = error
                f(e)
            }
        }
    }
    
    /// 处理成功
    func responseSuccess<T: ResponseProtocol>(request: RequestProtocol,
                                                         response: Response,
                                                         successClosure: @escaping Success<T>) {
        DispatchQueue.global().async {
            do {
                
                let responseSuccess = try response.filterSuccessfulStatusAndRedirectCodes()
                
                guard let responseDict = try JSONSerialization.jsonObject(with: responseSuccess.data, options: .mutableContainers) as? NSDictionary else {
                    let errorResp = MoyaError.jsonMapping(response)
                    if let f = self.failureClosure {
                        
                        DispatchQueue.main.safeAsync {
                            f(errorResp)
                        }
                    }
                    return
                }
                
                let ftResponse = T(requestModel: request, responseDict: responseDict, moyaResponse: response)
                
                if let resp = ftResponse as? ResponseErrorProtocol {
                    if resp.checkError(failureClosure: self.failureClosure) {
                        return
                    }
                }
                
                DispatchQueue.main.safeAsync {
                    successClosure(ftResponse)
                }
                
            } catch {
                
                DispatchQueue.main.safeAsync {
                    
                    let error = MoyaError.statusCode(response)
                    
                    if let f = self.failureClosure {
                        f(error)
                    }
                    
                    let ftResponse = T(requestModel: request, responseDict: nil, moyaResponse: response)
                    if let resp = ftResponse as? ResponseErrorProtocol {
                        resp.handleStatusCode(error: error)
                    }
                    
                }
                
            }
        }
    }
    
    
    /// 创建Provider
    private func createProvider(req: RequestProtocol) -> MoyaProvider<MultiTarget> {
        
        var trackInflights = false
        #if DEBUG
        trackInflights = true
        #endif
        
        let manager = defaultAlamofireManager(req: req)
        
        let provider = MoyaProvider<MultiTarget>(endpointClosure: defaultEndpointMapping,
                                                 requestClosure: defaultRequestMapping,
                                                 stubClosure: neverStub,
                                                 manager: manager,
                                                 plugins: defaultPlugins(),
                                                 trackInflights: trackInflights)
        
        let adapter = CustomRequestAdapter()
        adapter.timeout = req.timeOut
        provider.manager.adapter = adapter
        
        return provider
    }
    
}

public extension Net {
    
    final func defaultEndpointMapping(for target: MultiTarget) -> Endpoint {
        
        var sampleCode = 200
        if let req = target.target as? RequestProtocol {
            sampleCode = req.sampleCode
        }
        
        return Endpoint(url: URL(target: target).absoluteString,
                        sampleResponseClosure: {
                            .networkResponse(sampleCode, target.sampleData)
        },
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
    }
    
    final func neverStub(for target: MultiTarget) -> Moya.StubBehavior {
        if let req = target.target as? RequestProtocol, req.isStub {
            return .delayed(seconds: 1)
        }
        return .never
    }
    
    final func defaultRequestMapping(for endpoint: Endpoint, closure: MoyaProvider<MultiTarget>.RequestResultClosure) {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    final func defaultAlamofireManager(req: RequestProtocol) -> Manager {
        var manager: Manager
        switch req.requestType {
        case .httpsBoth(let policies):
            let policyManager = ServerTrustPolicyManager(policies: policies)
            manager = Manager(serverTrustPolicyManager: policyManager)
        case .http:
            manager = Manager()
        case .https:
            manager = Manager()
            manager.delegate.sessionDidReceiveChallenge = { session,challenge in
                return (URLSession.AuthChallengeDisposition.useCredential,
                        URLCredential(trust:challenge.protectionSpace.serverTrust!))
            }
        }
        return manager
    }
    
    func defaultPlugins() -> [PluginType] {
        /// 配置插件
        var plugins: [PluginType] = [PluginType]()
        
        #if DEBUG
        
        /// 添加打印log插件
        let logPlugin = NetworkLoggerPlugin(verbose: true,
                                            responseDataFormatter: JSONResponseDataFormatter)
        plugins.append(logPlugin)
        
        /// 添加状态栏风火轮插件
        let networkPlugin = NetworkActivityPlugin { (change, target)  -> () in
            DispatchQueue.main.safeAsync {
                switch(change){
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        plugins.append(networkPlugin)
        
        #endif
        
        return plugins
        
    }
}

private class CustomRequestAdapter: RequestAdapter {
    
    var timeout: TimeInterval = 30
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = timeout
        return urlRequest
    }
}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}
