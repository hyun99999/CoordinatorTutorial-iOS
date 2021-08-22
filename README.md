# CoordinatorTutorial-iOS
👊 Coordinator 패턴의 유쾌한 반란

**목차**

- [Basic](#basic)


: Coordinator pattern 을 프로젝트에 적용해보고 데이터 전달해보자.
- [Advanced](#advanced)


: parent, child coordinator 관계를 형성해보자.

# Basic

### 참고
- [간단한 예제로 살펴보는 iOS Design/Architecture Pattern: Coordinator - Basic](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_basic/)
- [[Swift] Coordinator Pattern (1/2) - 기본원리](https://nsios.tistory.com/48)


**위의 글을 참고해서 coordinator pattern 을 실습해보았다.**

## 초기설정

### 👊 SceneDelegate.swift 삭제

1. App Delegate에서 Scene delegate 메서드 삭제

<img width="500" alt="1" src="https://user-images.githubusercontent.com/69136340/130321532-679db695-02d5-46c1-be66-65d4d427e220.png">


2. Scene delegate file 삭제

<img width="200" alt="2" src="https://user-images.githubusercontent.com/69136340/130321535-ab74ce8f-80e9-4dcc-b0b4-82d2b9c765bd.png">


3. Info.plist에서 UIApplicationSceneManifest 삭제

<img width="400" alt="3" src="https://user-images.githubusercontent.com/69136340/130321538-55dff2ef-8958-4d2b-83ce-1d04eca8f08d.png">

4. AppDelegate에 `var window:UIWindow?` 추가

- Scene delegate가 추가된 iOS 13이후에는 위 과정을 거치지 않으면 Coordinator를 이용한 화면전환이 정상적으로 동작하지 않습니다.

## 👊 첫 화면을 실행해 보자

- Coordinator.swift

```swift
import Foundation
import UIKit

protocol  Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
```

- MainCoordinator.swfit

Coordinator 프로토콜을 채택해서 화면전환을 설정

```swift
import Foundation
import UIKit

class MainCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    // ✅ 앱이 보여질 때 처음 화면
    func start() {
        // ✅ 뷰컨트롤러 인스턴스 커스텀 메서드 
        let vc = ViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: false)
    }
}
```

- Storyboarded.swift

스토리보드에 접근해서 뷰컨트롤러의 이름을 identifier 로 가진 뷰컨트롤러를 손쉽게 인스턴스화하기 위한 `instantiate()` 메서드 구현.

```swift
import Foundation

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // ✅ ex) "CoordinatorPractice(프로젝트 이름).ViewController"
        let fullName = NSStringFromClass(self)

        // ✅ .을 기준으로 split해 "ViewController"만 추출
        let className = fullName.components(separatedBy: ".")[1]

        // ✅ Bundle.main에서 Main.storyboard 가져오기
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // ✅storyboard에 className을 identifier로 가지고 있는 ViewController 인스턴스화
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
```

<img width="261" alt="4" src="https://user-images.githubusercontent.com/69136340/130321550-85c59c4c-b67f-424f-bb82-b8eca4d8dc52.png">

다음과 같이 id 값을 설정해주어야 한다.

- ViewController.swift

```swift
import UIKit

class ViewController: UIViewController, Storyboarded {

    // ✅ MainCoorinator 추가
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```
- AppDelegate.swift

SeneDelegate.swift 를 삭제한 후 첫 화면을 실행하기 위한 코드

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let navigationContorller = UINavigationController()
        coordinator = MainCoordinator(navigationController: navigationContorller)
        coordinator?.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationContorller
        // ✅
        window?.makeKeyAndVisible()
        
        return true
    }
}
```

✅ [makeKeyAndVisible]([https://developer.apple.com/documentation/uikit/uiwindow/1621601-makekeyandvisible](https://developer.apple.com/documentation/uikit/uiwindow/1621601-makekeyandvisible))

- window 보여주기 및 keyWindow 설정 메서드.
- keyWindow: 키보드 및 터치 이벤트가 아닌 이벤트도 받을 수 있도록 등록
- window의 rootViewController를 위에서 세팅해주고 makeKeyAndVisible() 부르면 마침내 지정한 rootViewController가 상호작용을 받는 현재 화면으로 세팅 완료

**참고 :** 

[[iOS - swift] UIWindow, makeKeyAndVisible()](https://ios-development.tistory.com/314)

## 👊 화면 전환을 해보자

- Main.storyboard

<img width="600" alt="스크린샷 2021-08-21 오후 9 49 26" src="https://user-images.githubusercontent.com/69136340/130322687-32c10f10-df7d-46de-945b-2c1c24e0ebc7.png">

추가로 LeftViewController 와 RightViewController 를 만들어주고 ViewController 와 동일하게 `weak var coordinator: MainCoordinator?` 추가하고 `Storyboarded` 프로토콜을 채택해준다.

- MainCoordinator.swift

```swift
class MainCoordinator: NSObject, Coordinator {
    
    // ...
    
    // ✅ 추가 화면 전환
    func pushToLeftVC() {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self
        // ✅ push 되는 애니메이션 여부 true 설정
        nav.pushViewController(vc, animated: true)
    }
    
    func pushToRightVC() {
        let vc = RightViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: true)
    }
}
```

## 👊 데이터 전달

그렇다면 coordinator 패턴에서는 어떻게 화면전환 시 데이터를 전달해줄까?

비슷하다. MainCoordinator 의 화면전환 함수에 파라미터를 만들어준다. 그 후 뷰컨트롤러에서 호출할 때 파라미터를 전달받아서 화면전환할 뷰컨트롤러의 인스턴스에 넣어주면 된다.

- MainCoordinator.swift

```swift
class MainCoordinator: NSObject, Coordinator {

// ...

    func pushToLeftVC(string: String) {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self

        // ✅ 데이터 전달
        vc.string = string
        nav.pushViewController(vc, animated: true)
    }

// ...

}
```

- LeftViewController.swift

```swift
import UIKit

class LeftViewController: UIViewController, Storyboarded {

    // ✅ 데이터를 받을 옵셔널 변수
    var string: String?

    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ 전달된 데이터 확인
        if let string = string {
            print(string)
        }
    }
}
```

# Advanced

[간단한 예제로 살펴보는 iOS Design/Architecture Pattern: Coordinator - Advanced](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_advanced/)

이번 실습 역시 위의 글을 참고했다.

## 👊 parent coordinator & child coordinator

Basic 에서는 한개의 Coordinator 만 사용했었다. 그러다가 ‘용도별로, 화면별로 Coordinator 를 여러개 두고 사용할 수는 없을까?‘ 라는 생각에서 출발한 개념이 parent coordinator 와 child coordinator 이다.

<img width="700" alt="2" src="https://user-images.githubusercontent.com/69136340/130352611-e4b4f2a5-211d-43e1-998b-f62ae3b384ac.png">

두개 이상의 coordinator 를 사용할 때 위의 이미지처럼 parent 와 child coordinator 의 관계를 맺어서 사용할 수 있다. 기존의 프로젝트를 리펙토링하면서 진행해보자.

## 👊 Child Coordinator 생성

- LeftCoordinator.swift

MainCoorodinator 의 child coordinator 역할

```swift
import Foundation
import UIKit

class LeftCoordinator: Coordinator {
    // ✅ Coordinator 프로토콜을 채택해서 그대로 구현한 모습
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController

    // ✅ retain cycle을 피하기 위해 weak 참조로 선언해주세요.
    weak var parentCoordinator: MainCoordinator?

    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    func start() {
        // ✅ MainCoordinator 의 pushToLeftVC() 함수 구현부분을 옮긴다
        let vc = LeftViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: true)
    }
}
```

- LeftViewController.swift

```swift
import UIKit

class LeftViewController: UIViewController, Storyboarded {
    var string: String?

    // ✅ LeftViewController 에서는 LeftCoordinator 를 사용할 것이기 때문에 coordinator 변수타입을 LeftCoordinator 로 변경 
    weak var coordinator: LeftCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let string = string {
            print(string)
        }
    }
}
```

## 👊 Parent Coordinator 에서 Child Coordinator 간 관계를 맺어준다.

- MainCoordinator.swift

```swift
class MainCoordinator: Coordinator {
    
// ...
    
// ✅ 이전 과정에서 우리는 LeftCoordinator 로 이 구현 부분을 옮겼다.
//    func pushToLeftVC(string: String) {
//        let vc = LeftViewController.instantiate()
//        vc.coordinator = self
//        vc.string = string
//        nav.pushViewController(vc, animated: true)
//    }
    
    // ✅ parent 와 child coordinator 관계 설정
    func leftSubscriptions() {
        let child = LeftCoordinator(navigationController: nav)
        
        // ✅ LeftCoordinator 의 parent coordinator 로 MainCoordinator 설정
        child.parentCoordinator = self
        
        // ✅ child coordinator 을 저장하는 배열에 저장
        childCoordinators.append(child)
        
        // ✅ LeftViewController 로 화면전환
        child.start()
    }

// ...

}
```

## 👊 push 화면전환을 해보자

```swift
class ViewController: UIViewController, Storyboarded {

// ...
    
    @IBAction func pushToLeftVC(_ sender: Any) {
//        self.coordinator?.pushToLeftVC(string: "left")
        // ✅ 다음의 코드로 바꿔서 호출
        self.coordinator?.leftSubscriptions()
    }

// ...
}
```

## 👊 Child Coordinator 의 일이 끝났을 때

LeftViewController 에서 MainViewController 로 pop 할때 어떻게 해야할까?

parent coordinator 에게 알리고 child coordinator 를 지워야한다.

- MainCoordinator.swift

```swift
class MainCoordinator: Coordinator {

    // ✅ child coordinator 배열에서 지워야 할 coordinator 를 찾아서 제거하는 메서드
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {

            // ✅ === 연산자는 클래스의 두 인스턴스가 동일한 메모리를 가리키는지에 대한 연산(그래서 === 연산자를 사용하기 위해서 Coordinator 를 클레스 전용 프로토콜(class-only protocol) 로 만들어준다.)
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
```

- Coordinator.swift

`===` 연산자를 사용하기 위해서 Coordinator 를 클레스 전용 프로토콜(class-only protocol) 로 만들어준다.

```swift
protocol Coordinator: AnyObject {

// ...

}
```

## 👊 그렇다면 언제 child coordinator 를 지우는 메서드를 호출할까?

바로 화면이 사라질 때 호출하면 된다. 화면이 사라질 시점에 이 작업을 하기 위해서는 ViewController의 `viewDidDisappear()` 메서드나 Navigation Controller Delegate의 `didShow()` 메서드에서 위 메서드를 호출하면 된다.

다음 두 가지 방법을 소개하겠다.

### 1️⃣ 첫번째: UIViewController의 viewDidDisappear() 사용

child coordinator 의 할 일이 끝났다는걸 parent coordinator 에게 알리기 위해서 UIViewController 의 라이프사이클 메서드를 사용한다.

- LeftCoordinator.swift

```swift
class LeftCoordinator: Coordinator {
    
// ...

    func didFinishLeft() {
        parentCoordinator?.childDidFinish(self)
    }
}
```

- LeftViewController.swift

화면이 사라지는 시점인 viewDidDisappear() 에서 호출해준다.

```swift
class LeftViewController: UIViewController, Storyboarded {

    weak var coordinator: LeftCoordinator?
    
// ...
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLeft()
    }
}
```

### 2️⃣ 두번째: UINavigationControllerDelegate의 didShow() 사용

❗️이 방법에서는 viewDidDisappear()를 사용하지 않는다.
MainCoordinator 가 Navigation Controller의 상호작용을 바로 감지할 수 있기 때문이라고 한다.
coordinator가 관리하는 ViewController가 많을수록 coordinator 스택에 혼동이 오는 걸 피하기 위해 Navigation Controller Delegate를 채택하는 방법을 추천한다고 한다.

- MainCoordinator.swift

MainCoordinator 클래스에 NSObject를 상속하고 UINavigationControllerDelegate 를 채택해줍니다.

```swift
// ✅ NSObject 상속
class MainCoordinator: NSObject, Coordinator {
    
    // ...

    var nav: UINavigationController
    
    // ...

    func start() {
        let vc = ViewController.instantiate()
        vc.coordinator = self

        // ✅ nav 의 delegate 를 self 로 설정
        nav.delegate = self
        nav.pushViewController(vc, animated: false)
    }

    // ...

}

// ✅ UINavigationControllerDelegate 채택 및 didShow() 메서드 구현
extension MainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        // 이동 전 ViewController
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
           return
        }

        // fromViewController가 navigationController의 viewControllers에 포함되어있으면 return. 왜냐하면 여기에 포함되어있지 않아야 현재 fromViewController 가 사라질 화면을 의미.
        if navigationController.viewControllers.contains(fromViewController) {
           return
        }

        // child coordinator 가 일을 끝냈다고 알림.
        if let leftVC = fromViewController as? LeftViewController {
           childDidFinish(leftVC.coordinator)
        }
    }
}

```

✅ [didShow()](https://developer.apple.com/documentation/uikit/uinavigationcontrollerdelegate/1621848-navigationcontroller)

: navigation controller 가 view controller 의 뷰와 navigation item properties 를 보여준 후 호출된다.

## 👊 커스텀 뒤로가기 버튼을 만든 경우는?

우리가 쓰던대로 `popViewController(animated:)` 메서드를 사용하면 된다. 이 메서드를 사용하면 navigation bar에 있는 back 버튼( < )을 눌렀을 때와 동일하게 `didShow()` 와 `childDidFinish()`  가 호출됩니다.

- LeftViewController.swift

```swift
class LeftViewController: UIViewController, Storyboarded {

    // ...
    
    @IBAction func popToMain(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
```

## 👊 child coordinators 가 제대로 비워지는지 살펴보자

breakpoint 를 주어서 제거당시의 childCoordinators 배열을 출력해보았다.

<img width="700" alt="1" src="https://user-images.githubusercontent.com/69136340/130352626-57fc7f56-69a0-4644-8b37-78a441063703.png">

## 👊 느낀점

굳이 coordinator 패턴을 사용해서 화면전환을 해야할까 싶었다. pop 은 그대로 사용하고 push 만 설정해주는 것인데 오히려 신경쓸게 늘었고 초기 설정의 장벽이 높은 느낌이었다. 하지만 

❗️정말 화면전환을 뷰컨트롤러에서 분리시켜서 massive 한 뷰컨트롤러를 피하고 싶은 경우 사용하기 좋다고 생각했다.

❗️화면이 많아질수록 뷰컨트롤러에 화면을 전환하는 코드가 흩어져있어서 파악, 관리하기 어려운 경우에 사용하기 좋다고 생각했다.

위의 두가지 경우에 대해서는 장점이 있었다. 하지만 필요할때 사용하지 않으면 오버스택이라고 생각했다 말그대로 디자인패턴을 맹신하면 안된다고 느꼈다.

출처 : 

[간단한 예제로 살펴보는 iOS Design/Architecture Pattern: Coordinator - Advanced](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_advanced/)
