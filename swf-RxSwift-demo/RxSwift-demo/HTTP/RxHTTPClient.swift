//
//  RxHTTPClient.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/14.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import Foundation
import RxSwift

final class RxHTTPClient {
    
    func fetchData(request: URLRequest) -> Observable<Data> {
        
        return Observable.create { observer in
            // subscribeされた時の処理
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) { data, response, error in
                if let data = data {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(error!)
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
