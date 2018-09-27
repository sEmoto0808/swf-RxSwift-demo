//
//  RxHTTPViewController.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/14.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxHTTPViewController: UIViewController {
    
    @IBOutlet weak var fetchButton: UIButton!
    @IBOutlet weak var loadingView: UILabel!
    @IBOutlet weak var successView: UILabel!
    
    private let httpClient = RxHTTPClient()
    private var httpVM: RxHTTPViewModel!
    private var httpOutput: RxHTTPViewModel.Output!
    
    let disposeBag = DisposeBag()  // unsubscribeに必要なもの
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var input = RxHTTPViewModel.Input.init()
        input.url = "https://www.apple.com/jp/"
        
        httpVM = RxHTTPViewModel(observale: fetchButton.rx.tap, input: input)
        
        httpOutput = httpVM.state()
//        httpOutput.loaded
//            .emit(onNext: { data in
//                print("success: \(data)")
//            },
//                  onCompleted: { print("complete") })
//            .disposed(by: disposeBag)
//
//        httpOutput.isLoading
//            .drive(onNext: { [weak self] in
//                guard let weakSelf = self else { return }
//                weakSelf.loadingView.isHidden = !$0
//                weakSelf.successView.isHidden = $0
//            })
//            .disposed(by: disposeBag)
        
        // ボタンをタップしたら通信する        
        fetchButton.rx.tap
            .asSignal()
            .emit(onNext: { [weak self] _ in
                guard let weakSelf = self else { return }
                weakSelf.successView.isHidden = true
                weakSelf.setOutputObserver()
                weakSelf.httpVM.fetchData()
            }).disposed(by: disposeBag)
    }
}

extension RxHTTPViewController {
    
    private func setOutputObserver() {
        
        httpOutput.loaded
            .emit(onNext: { data in
                print("success: \(data)")
            },
                  onCompleted: { print("complete") })
            .disposed(by: disposeBag)
        
        httpOutput.isLoading
            .emit(onNext: { [weak self] in
                print("loading: \($0)")
                guard let weakSelf = self else { return }
                weakSelf.loadingView.isHidden = !$0
                weakSelf.successView.isHidden = $0
            },
                   onCompleted: { print("complete") })
            .disposed(by: disposeBag)
    }
}
