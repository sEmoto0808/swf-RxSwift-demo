//
//  RxHTTPViewController.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/14.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import UIKit
import RxSwift

class RxHTTPViewController: UIViewController {
    
    private let httpClient = RxHTTPClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "")
        let request = URLRequest(url: url!)
        
        _ = httpClient.fetchData(request: request)
            .observeOn(MainScheduler.instance)  // これ以降の処理がメインスレッド
            .subscribe(onNext: { data in
                        // success
            },
                       onError: { error in
                        // failed
            })
    }
}
