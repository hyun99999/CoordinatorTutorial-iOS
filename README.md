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
