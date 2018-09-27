//
//  RxHTTPViewModel.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/27.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class RxHTTPViewModel {
    
    struct Input {
        var url = ""
    }
    
//    struct Output {
//        let data: [String]
//    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let loaded: Signal<[String]>
        let failed: Driver<Bool>
    }
    
    private let httpModel = RxHTTPModel()
    private var vmInput: RxHTTPViewModel.Input!
    private var vmOutput: RxHTTPViewModel.Output!
    
    //////
    private var tappedFetch: ControlEvent<Void>!
    //////
    
    let disposeBag = DisposeBag()  // unsubscribeに必要なもの
    
    init(observale: ControlEvent<Void>, input: RxHTTPViewModel.Input) {
        
        vmInput = input
        tappedFetch = observale
        
        let isLoading = httpModel.isLoading.asSignal()
//        let loaded = Driver.combineLatest(httpModel.data.asDriver(),
//                                          httpModel.error.asDriver().map {$0 != nil},
//                                          resultSelector: { ($1) ? [] : $0 })
        let loaded = httpModel.data.asSignal()
        
        let failed = httpModel.error.asDriver().map({ $0 != nil })
        
        vmOutput = RxHTTPViewModel.Output.init(isLoading: isLoading, loaded: loaded, failed: failed)
    }
    
    func state() -> RxHTTPViewModel.Output {
        return vmOutput
    }
    
    func fetchData() {
        httpModel.request(url: vmInput.url)
    }
}
