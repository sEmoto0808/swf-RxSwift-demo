//
//  RxHTTPModel.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/27.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class RxHTTPModel {
    
    let isLoading = PublishRelay<Bool>()
    let data = PublishRelay<[String]>()
    let error: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    
    private let httpClient = RxHTTPClient()
    
    func request(url: String?) {
        
        print("スタート")
        
        isLoading.accept(true)
        error.accept(nil)
        
        guard let urlStr = url else {
            isLoading.accept(false)
            return
        }
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        
        _ = httpClient.fetchData(request: request)
            .observeOn(MainScheduler.instance)  // これ以降の処理がメインスレッド
            .subscribe(onNext: { [weak self] data in
                // success
                sleep(10)
                guard let weakSelf = self else { return }
                weakSelf.isLoading.accept(false)
                weakSelf.data.accept(["1", "2", "3"])
            },
                       onError: { [weak self] error in
                        // failed
                        sleep(10)
                        guard let weakSelf = self else { return }
                        weakSelf.isLoading.accept(false)
                        weakSelf.data.accept([])
                        weakSelf.error.accept(error)
                },
                       onCompleted: { [weak self] in
                        // completed
                        sleep(10)
                        guard let weakSelf = self else { return }
                        weakSelf.isLoading.accept(false)
            })
    }
}
