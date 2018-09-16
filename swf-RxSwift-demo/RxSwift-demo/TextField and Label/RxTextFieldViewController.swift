//
//  RxTextFieldViewController.swift
//  RxSwift-demo
//
//  Created by Sho Emoto on 2018/09/06.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import UIKit
import RxSwift  // 4.2.0
import RxCocoa  // 4.2.0

class RxTextFieldViewController: UIViewController {

    @IBOutlet weak var rxDemoLabel: UILabel!
    @IBOutlet weak var rxDemoTextField: UITextField!
    @IBOutlet weak var rxMessageLabel: UILabel!
    
    let disposeBag = DisposeBag()  // unsubscribeに必要なもの
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Observable
        
        // TextFieldの変更をLabelに反映する
        rxDemoTextField.rx.text
            .orEmpty
            .throttle(0.1, scheduler: MainScheduler.instance)  // 監視する間隔
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] text in
                self.rxDemoLabel.text = text
                self.rxMessageLabel.isHidden = text.lengthOfBytes(using: String.Encoding.utf8) >= 5
            })
            .disposed(by: disposeBag)
        
        // MARK: - Subject
        
        /// PublishSubject
        /// PublishSubjectはsubscribeされた時点移行のイベントを検知できる
        print("---- PublishSubject ----")
        let publishSubject = PublishSubject<String>()
        
        publishSubject.onNext("PublishSubject before: a")  // subscribeする前はイベントは無効
        
        publishSubject.subscribe({ event in
            print(event)
        }).disposed(by: disposeBag)
        
        publishSubject.onNext("PublishSubject after: a")  // print -> next(after: a)
        
        
        /// ReplaySubject
        /// 指定した数だけ最新のイベントをキャッシュさせることができ、subscribeされたタイミングでキャッシュされてるイベントが送信されます
        print("---- ReplaySubject ----")
        let replaySubject = ReplaySubject<String>.create(bufferSize: 2)
        
        replaySubject.onNext("ReplaySubject before: a")  // subscribe①のキャッシュ
        replaySubject.onNext("ReplaySubject before: b")  // subscribe①のキャッシュ
        
        replaySubject.subscribe({ event in
            print("1 \(event)")
        }).disposed(by: disposeBag)
        
        replaySubject.onNext("ReplaySubject before: c")  // subscribe②のキャッシュ
        replaySubject.onNext("ReplaySubject before: d")  // subscribe②のキャッシュ

        replaySubject.subscribe({ event in
            print("2 \(event)")
        }).disposed(by: disposeBag)

        replaySubject.onNext("ReplaySubject after: e")
        replaySubject.onNext("ReplaySubject after: f")
        
        
        /// BehaviorSubject
        /// ReplaySubjectのbufferSizeが1のときと同様の挙動
        /// これまで扱ってきたものはイベントを発生検知することができイベントに値は含まれるものの、常に値を持つものではありませんでした。
        /// BehaviorSubjectは、現在値を取得できるvalueメソッドを持っています。ただし、ObservableでもあるのでonErrorやonCompletedが既に発生している可能性があるのでvalueメソッドを使う際はその分岐を加える必要があります。
        
        
        /// Variable
        /// BehaviorSubjectからObservableを取り除いたようなもの
        /// onError,onCompletedは発生させません
        /// Observableとして使いたい場合は、asObservableメソッドを呼ぶことでObservableに変換することができます。すなわち値を格納することもでき、変更を検知したい場合はObservableに変更して購読するようにできます。
        print("---- Variable ----")
        let variable: Variable<String> = Variable("a")
        
        variable
            .asObservable()
            .subscribe({ event in
                print(event)
            })
            .disposed(by: disposeBag)
        
        variable.value = "b"  // subscribe内の処理が走る
    }
}
