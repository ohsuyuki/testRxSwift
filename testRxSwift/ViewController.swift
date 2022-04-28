//
//  ViewController.swift
//  testRxSwift
//
//  Created by yuki.osu on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
            return catchError { _ in
                return Observable.empty()
            }
        }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
        
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var label1: UILabel!
    
    let disposeBag = DisposeBag()
    var tapGesture: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

#if false
//        let odd = RxSwift.Observable.of(1,3,5)
//        let even = RxSwift.Observable.of(2)

//        RxSwift.Observable.concat(odd, even)
//            .debug()
//            .subscribe()

//        odd.withLatestFrom {
//            print("withLatestFrom: \($0), \($1)")
//        }

//        odd.withLatestFrom(even) { (odd, even) in return (odd, even)}
//        .debug()
//        .subscribe()

//        odd.withLatestFrom(even)
//            .debug()
//            .subscribe()

//        odd.withLatestFrom(even) { return ($0, $1) }
//        .debug()
//        .subscribe()

//        odd.withLatestFrom(even) { return ($0, $1) }
//        .debug()
//        .subscribe()

//        odd.withLatestFrom(even) { ($0, $1) }
//        .debug()
//        .subscribe()

//        let behaivor = BehaviorSubject<Bool>(value: false)
        let reley = PublishRelay<Bool>()
        let driver: Driver<Bool> = reley.asDriver(onErrorJustReturn: false)

        self.button1.rx.tap
            .debug()
            .subscribe(onNext: { [weak self] in
//                behaivor.onNext(!self!.button2.isEnabled)
                reley.accept(!self!.button2.isEnabled)
            })
            .disposed(by: self.disposeBag)

//        behaivor.asDriver(onErrorJustReturn: true)
//            .drive(button2.rx.isEnabled)
//            .disposed(by: self.disposeBag)
        driver.drive(button2.rx.isEnabled)
            .disposed(by: self.disposeBag)

        text1.rx.text.asDriver()
            .drive(onNext: { (text) in
                print("[test] \(text)")
            })
            .disposed(by: self.disposeBag)

        let placeHolderReley = PublishRelay<String>()
        let placeHolderDriver: Driver<String> = placeHolderReley.asDriver(onErrorJustReturn: "")
        
//        let rxPrice: Driver<String?>
//        rxPrice = text1.rx.text.asDriver()
//            .filter { $0 != nil && $0!.count > 0 }
//            .map { Int($0!) }
//            .map { String($0!) }

        let driverPrice = text1.rx.text.asDriver()

        let rxPrice: Driver<String?> = driverPrice
            .map { (price) -> String? in
                guard let price = price,
                      price.count > 0 else {
                    return nil
                }
//                return price.replacingOccurrences(of: ",", with: "").toInt
                return price
            }

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .asDriverOnErrorJustComplete()
            .map { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .filter { $0 != nil }
            .drive(onNext: { [weak self] (frame) in
                self?.view.transform = CGAffineTransform(translationX: 0, y: -frame!.height / 2)
            })
            .disposed(by: self.disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] (frame) in
                self?.view.transform = .identity
            })
            .disposed(by: self.disposeBag)

        Driver.merge([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .map { notification -> (Bool, Notification) in
                    (true, notification)
                }.asDriverOnErrorJustComplete(),
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .map { notification -> (Bool, Notification) in
                    (false, notification)
                }.asDriverOnErrorJustComplete()])
            .drive(onNext: { [weak self] (isKeyboardShown, notification) in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                if isKeyboardShown {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height / 2)
                } else {
                    self.view.transform = .identity
                }
            }).disposed(by: disposeBag)

//        rxPrice = input.inputPrice.drive(onNext: { (price) in
//            guard let price = price, price.count > 0 else {
//                rxPrice.accept(nil)
//                return
//            }
//            if let intValue = price.replacingOccurrences(of: ",", with: "").toInt {
//                rxPrice.accept("\(intValue.currencyRepresentation)")
//            }
//        }).disposed(by: disposeBag)

        self.label1.isUserInteractionEnabled = true
        self.tapGesture = UITapGestureRecognizer()
        self.label1.addGestureRecognizer(self.tapGesture)
        self.tapGesture.rx.event.subscribe(onNext: { _ in
            print("tap!!")
        })

//        label1.rx.tap.sub {
//            print("tap!!")
//        }

        coldHot()
#endif
//        let single: Observable<Int> = Single.just(100).asObservable().share(replay: 1)
//        single
//            .debug()
//            .subscribe(onNext: { num in
//                print("subscribe 1 \(num)")
//            })
//            .disposed(by: self.disposeBag)

#if false
        let single: Single<Int> = Single.just(100)
        single
            .debug()
            .subscribe(onSuccess: { num in
                print("subscribe 1 \(num)")
            })
            .disposed(by: self.disposeBag)

        print("sleep start")
        sleep(1)
        print("sleep end")

//        let v: Observable<Void> = Observable.just(())
//        v
//            .withLatestFrom(single)
//            .subscribe(onNext: { num in
//                print("subscribe 2 \(num)")
//            })
//            .disposed(by: self.disposeBag)
        
        let v: Observable<Int> = Observable.just(10)
//        v
//            .withLatestFrom(single)
//            .subscribe(onNext: { num in
//                print("subscribe 2 \(num)")
//            })
//            .disposed(by: self.disposeBag)

        Observable.combineLatest(
            single.asObservable(),
            v
        )
        .subscribe(onNext: { (num1, num2) in
            print("subscribe 2 \(num1) \(num2)")
        })
        .disposed(by: self.disposeBag)
#endif
        let stream1: Observable<Int> = Single<Int>.create { (observer) -> Disposable in
            DispatchQueue.init(label: "stream1").async {
                Thread.sleep(forTimeInterval: 1.0)
                print("api call")
                observer(.success(1))
            }
            return Disposables.create()
        }
        .asObservable()
        .share(replay: 1)
        .debug("[stream 1]", trimOutput: false)

        let relay1: PublishRelay<Int> = PublishRelay<Int>()
        stream1.subscribe(onNext: { (_stream1) in
            relay1.accept(_stream1)
        })
        .disposed(by: disposeBag)
        let releyObs1: Observable<Int> = relay1.asObservable().share(replay: 1)

        button1.rx.tap.subscribe(onNext: {
            print("--------------------------------------")
            self.testStream2(stream1: releyObs1)
//            self.testStream2(stream1: stream1)
        })
        .disposed(by: disposeBag)

        stream1
            .debug("[stream 1] subscrbie", trimOutput: false)
            .subscribe()
            .disposed(by: disposeBag)

//        testStream2(stream1: releyObs1)
        testStream2(stream1: stream1)

        button2.rx.tap.subscribe(onNext: {
            stream1.subscribe()
        })
        .disposed(by: disposeBag)
    }

    var direct: Observable<Void>!
    var indirect: Observable<Void>!

    #if  true
    func testStream2(stream1: Observable<Int>) {
        let stream2: Single<Int> = Single<Int>.create { (observer) -> Disposable in
            DispatchQueue.init(label: "stream2").async {
//                Thread.sleep(forTimeInterval: 2.0)
                observer(.success(2))
            }
            return Disposables.create()
        }

        stream2.asObservable()
            .debug("[stream 2]", trimOutput: false)
            .withLatestFrom(stream1) { ($0, $1) }
            .debug("[stream 2] withLatestFrom", trimOutput: false)
            .subscribe(onNext: { (_stream2, _stream1) in
                print("_stream2: \(_stream2), _stream1: \(_stream1)")
            })
            .disposed(by: self.disposeBag)
//        Observable.combineLatest(
//            stream2.asObservable(),
//            stream1
//        )
//        .subscribe(onNext: { (_stream2, _stream1) in
//            print("_stream2: \(_stream2), _stream1: \(_stream1)")
//        })
//        .disposed(by: disposeBag)

    }
    #else
    func testStream2(stream1: Observable<Int>) {
        let stream2: Single<Int> = Single<Int>.create { (observer) -> Disposable in
            DispatchQueue.init(label: "stream2").async {
//                Thread.sleep(forTimeInterval: 2.0)
                observer(.success(2))
            }
            return Disposables.create()
        }

        Observable.combineLatest(
            stream2.asObservable(),
            stream1
        )
        .subscribe(onNext: { (_stream2, _stream1) in
            print("_stream2: \(_stream2), _stream1: \(_stream1)")
        })
        .disposed(by: disposeBag)

    }
    #endif

}

extension ViewController {

    func coldHot() {
//        let publish = PublishRelay<Void>()
//        let direct = publish
//            .debug("[test] direct", trimOutput: false)
//            .subscribe()
//        let indirect = publish.asObservable()
//            .debug("[test] indirect", trimOutput: false)
//            .subscribe()

        let publish = PublishSubject<Void>()
        publish
            .debug("[test] direct", trimOutput: false)
            .subscribe()
            .disposed(by: disposeBag)
        publish.asObservable()
            .debug("[test] indirect", trimOutput: false)
            .share(replay: 1)

        publish.on(.next(()))
    }
}
