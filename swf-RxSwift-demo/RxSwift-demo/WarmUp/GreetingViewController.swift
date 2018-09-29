//
//  ViewController.swift
//  rxswf-UIParts-demo
//
//  Created by Sho Emoto on 2018/09/28.
//  Copyright © 2018年 Sho Emoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GreetingViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    
    // MARK: - Outlet Collection
    @IBOutlet var greetingButtons: [UIButton]!
    
    // MARK: - Properties
    
    // 観測対象の一括解放
    private let disposeBag = DisposeBag()
    
    private enum SegmentState:Int {
        case useButtons
        case useTextField
    }
    
    // 初期値
    private var lastSelectedGreeting: BehaviorRelay<String> = BehaviorRelay(value: "こんにちは")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - 文字入力
        
        // 入力された文字列を観測対象にする
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
        
        // 名前入力欄と自由入力欄に入力された値の最新値を結合する
        let freewordWithName: Observable<String?> = Observable
            .combineLatest(nameObservable,
                           freeObservable) { (name:String?, freeword:String?) in
                            guard let name = name, let freeword = freeword else { return "" }
                            return name + freeword
        }
        
        // 上記で生成した文字列を表示する
        // 紐づけるUIパーツをbind(to:)の引数に指定する
        freewordWithName.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
        // MARK: - Segment切替
        
        // セグメントコントロールの値変化を観測対象にする
        let segmentObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
        
        // セグメントコントロールの値変化を検知して、その状態に対するenumを返す
        // Int -> SegmentState への変換
        let stateObservable: Observable<SegmentState> = segmentObservable
            .map({ (selectedIndex:Int) -> SegmentState in
                guard let state = SegmentState(rawValue: selectedIndex) else {return SegmentState.useButtons}
                return state
            })
        
        // セグメントコントロールの値変化を検知して、テキストフィールドの入力可否を返す
        // SegmentState -> Bool への変換
        let freeTextFieldEnabledObservable: Observable<Bool> = stateObservable
            .map({ (state: SegmentState) -> Bool in
                return state == .useTextField
            })
        
        // 入力可否をテキストフィールドにバインドする
        freeTextFieldEnabledObservable.bind(to: freeTextField.rx.isEnabled).disposed(by: disposeBag)
        
        // テキストフィールドの入力可否の変化を検知して、ボタンの選択可否を返す
        // Bool -> Bool への変換
        let buttonsEnabledObservable: Observable<Bool> = freeTextFieldEnabledObservable
            .map({ (freeEnabled:Bool) -> Bool in
                return !freeEnabled
            })
        
        // アウトレットコレクションの処理
        greetingButtons.forEach { button in
            // ボタンの選択可否をバインドする
            buttonsEnabledObservable.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
            
            // lastSelectedGreetingに選択したボタンのタイトルを渡す
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let weakSelf = self, let title = button.currentTitle else { return }
                    weakSelf.lastSelectedGreeting.accept(title)
                })
                .disposed(by: disposeBag)
        }
        
        // 挨拶文表示を観測対象にする
        let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()
        
        // 最終的な挨拶文を生成する
        let finalGreetingObservable: Observable<String> = Observable
            .combineLatest(stateObservable,
                           freeObservable,
                           predefinedGreetingObservable,
                           nameObservable) { (state: SegmentState, freeword: String?, predefinedGreeting: String, name: String?) -> String in
                            guard let freeword = freeword, let name = name else { return ""}
                            switch state {
                            case .useTextField:
                                return freeword + name
                            case .useButtons:
                                return predefinedGreeting + name
                            }
        }
        
        // 最終的な挨拶文を表示する
        finalGreetingObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
    }


}

extension GreetingViewController {
    
    private func setObservable() {
        
    }
}
