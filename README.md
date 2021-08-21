# CoordinatorTutorial-iOS
👊 Coordinator 패턴의 유쾌한 반란

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
