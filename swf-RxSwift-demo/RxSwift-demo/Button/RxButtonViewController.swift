//
//  RxButtonViewController.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/13.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxButtonViewController: UIViewController {

    @IBOutlet weak var rxButton: UIButton!
    
    let disposeBag = DisposeBag()  // unsubscribeに必要なもの
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ボタンをタップした時の処理
        rxButton.rx.tap
            .subscribe { [unowned self] _ in
                self.view.backgroundColor = UIColor.red
            }
            .disposed(by: disposeBag)
    }
}
