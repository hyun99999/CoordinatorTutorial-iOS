# CoordinatorTutorial-iOS
๐ Coordinator ํจํด์ ์ ์พํ ๋ฐ๋

**๋ชฉ์ฐจ**

- [Basic](#basic)


: Coordinator pattern ์ ํ๋ก์ ํธ์ ์ ์ฉํด๋ณด๊ณ  ๋ฐ์ดํฐ ์ ๋ฌํด๋ณด์.
- [Advanced](#advanced)


: parent, child coordinator ๊ด๊ณ๋ฅผ ํ์ฑํด๋ณด์.

# Basic

### ์ฐธ๊ณ 
- [๊ฐ๋จํ ์์ ๋ก ์ดํด๋ณด๋ iOS Design/Architecture Pattern: Coordinator - Basic](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_basic/)
- [[Swift] Coordinator Pattern (1/2) - ๊ธฐ๋ณธ์๋ฆฌ](https://nsios.tistory.com/48)


**์์ ๊ธ์ ์ฐธ๊ณ ํด์ coordinator pattern ์ ์ค์ตํด๋ณด์๋ค.**

## ์ด๊ธฐ์ค์ 

### ๐ SceneDelegate.swift ์ญ์ 

1. App Delegate์์ Scene delegate ๋ฉ์๋ ์ญ์ 

<img width="500" alt="1" src="https://user-images.githubusercontent.com/69136340/130321532-679db695-02d5-46c1-be66-65d4d427e220.png">


2. Scene delegate file ์ญ์ 

<img width="200" alt="2" src="https://user-images.githubusercontent.com/69136340/130321535-ab74ce8f-80e9-4dcc-b0b4-82d2b9c765bd.png">


3. Info.plist์์ UIApplicationSceneManifest ์ญ์ 

<img width="400" alt="3" src="https://user-images.githubusercontent.com/69136340/130321538-55dff2ef-8958-4d2b-83ce-1d04eca8f08d.png">

4. AppDelegate์ย `var window:UIWindow?`ย ์ถ๊ฐ

- Scene delegate๊ฐ ์ถ๊ฐ๋ iOS 13์ดํ์๋ ์ ๊ณผ์ ์ ๊ฑฐ์น์ง ์์ผ๋ฉด Coordinator๋ฅผ ์ด์ฉํ ํ๋ฉด์ ํ์ด ์ ์์ ์ผ๋ก ๋์ํ์ง ์์ต๋๋ค.

## ๐ ์ฒซ ํ๋ฉด์ ์คํํด ๋ณด์

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

Coordinator ํ๋กํ ์ฝ์ ์ฑํํด์ ํ๋ฉด์ ํ์ ์ค์ 

```swift
import Foundation
import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    // โ ์ฑ์ด ๋ณด์ฌ์ง ๋ ์ฒ์ ํ๋ฉด
    func start() {
        // โ ๋ทฐ์ปจํธ๋กค๋ฌ ์ธ์คํด์ค ์ปค์คํ ๋ฉ์๋ 
        let vc = ViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: false)
    }
}
```

- Storyboarded.swift

์คํ ๋ฆฌ๋ณด๋์ ์ ๊ทผํด์ ๋ทฐ์ปจํธ๋กค๋ฌ์ ์ด๋ฆ์ identifier ๋ก ๊ฐ์ง ๋ทฐ์ปจํธ๋กค๋ฌ๋ฅผ ์์ฝ๊ฒ ์ธ์คํด์คํํ๊ธฐ ์ํ `instantiate()` ๋ฉ์๋ ๊ตฌํ.

```swift
import Foundation

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // โ ex) "CoordinatorPractice(ํ๋ก์ ํธ ์ด๋ฆ).ViewController"
        let fullName = NSStringFromClass(self)

        // โ .์ ๊ธฐ์ค์ผ๋ก splitํด "ViewController"๋ง ์ถ์ถ
        let className = fullName.components(separatedBy: ".")[1]

        // โ Bundle.main์์ Main.storyboard ๊ฐ์ ธ์ค๊ธฐ
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // โstoryboard์ className์ identifier๋ก ๊ฐ์ง๊ณ  ์๋ ViewController ์ธ์คํด์คํ
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
```

<img width="261" alt="4" src="https://user-images.githubusercontent.com/69136340/130321550-85c59c4c-b67f-424f-bb82-b8eca4d8dc52.png">

๋ค์๊ณผ ๊ฐ์ด id ๊ฐ์ ์ค์ ํด์ฃผ์ด์ผ ํ๋ค.

- ViewController.swift

```swift
import UIKit

class ViewController: UIViewController, Storyboarded {

    // โ MainCoorinator ์ถ๊ฐ
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```
- AppDelegate.swift

SeneDelegate.swift ๋ฅผ ์ญ์ ํ ํ ์ฒซ ํ๋ฉด์ ์คํํ๊ธฐ ์ํ ์ฝ๋

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
        // โ
        window?.makeKeyAndVisible()
        
        return true
    }
}
```

โ [makeKeyAndVisible]([https://developer.apple.com/documentation/uikit/uiwindow/1621601-makekeyandvisible](https://developer.apple.com/documentation/uikit/uiwindow/1621601-makekeyandvisible))

- window ๋ณด์ฌ์ฃผ๊ธฐ ๋ฐ keyWindow ์ค์  ๋ฉ์๋.
- keyWindow: ํค๋ณด๋ ๋ฐ ํฐ์น ์ด๋ฒคํธ๊ฐ ์๋ ์ด๋ฒคํธ๋ ๋ฐ์ ์ ์๋๋ก ๋ฑ๋ก
- window์ rootViewController๋ฅผ ์์์ ์ธํํด์ฃผ๊ณ  makeKeyAndVisible() ๋ถ๋ฅด๋ฉด ๋ง์นจ๋ด ์ง์ ํ rootViewController๊ฐ ์ํธ์์ฉ์ ๋ฐ๋ ํ์ฌ ํ๋ฉด์ผ๋ก ์ธํ ์๋ฃ

**์ฐธ๊ณ  :** 

[[iOS - swift] UIWindow, makeKeyAndVisible()](https://ios-development.tistory.com/314)

## ๐ ํ๋ฉด ์ ํ์ ํด๋ณด์

- Main.storyboard

<img width="600" alt="แแณแแณแแตแซแแฃแบ 2021-08-21 แแฉแแฎ 9 49 26" src="https://user-images.githubusercontent.com/69136340/130322687-32c10f10-df7d-46de-945b-2c1c24e0ebc7.png">

์ถ๊ฐ๋ก LeftViewController ์ RightViewController ๋ฅผ ๋ง๋ค์ด์ฃผ๊ณ  ViewController ์ ๋์ผํ๊ฒ `weak var coordinator: MainCoordinator?` ์ถ๊ฐํ๊ณ  `Storyboarded` ํ๋กํ ์ฝ์ ์ฑํํด์ค๋ค.

- MainCoordinator.swift

```swift
class MainCoordinator: Coordinator {
    
    // ...
    
    // โ ์ถ๊ฐ ํ๋ฉด ์ ํ
    func pushToLeftVC() {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self
        // โ push ๋๋ ์ ๋๋ฉ์ด์ ์ฌ๋ถ true ์ค์ 
        nav.pushViewController(vc, animated: true)
    }
    
    func pushToRightVC() {
        let vc = RightViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: true)
    }
}
```

## ๐ ๋ฐ์ดํฐ ์ ๋ฌ

๊ทธ๋ ๋ค๋ฉด coordinator ํจํด์์๋ ์ด๋ป๊ฒ ํ๋ฉด์ ํ ์ ๋ฐ์ดํฐ๋ฅผ ์ ๋ฌํด์ค๊น?

๋น์ทํ๋ค. MainCoordinator ์ ํ๋ฉด์ ํ ํจ์์ ํ๋ผ๋ฏธํฐ๋ฅผ ๋ง๋ค์ด์ค๋ค. ๊ทธ ํ ๋ทฐ์ปจํธ๋กค๋ฌ์์ ํธ์ถํ  ๋ ํ๋ผ๋ฏธํฐ๋ฅผ ์ ๋ฌ๋ฐ์์ ํ๋ฉด์ ํํ  ๋ทฐ์ปจํธ๋กค๋ฌ์ ์ธ์คํด์ค์ ๋ฃ์ด์ฃผ๋ฉด ๋๋ค.

- MainCoordinator.swift

```swift
class MainCoordinator: NSObject, Coordinator {

// ...

    func pushToLeftVC(string: String) {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self

        // โ ๋ฐ์ดํฐ ์ ๋ฌ
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

    // โ ๋ฐ์ดํฐ๋ฅผ ๋ฐ์ ์ต์๋ ๋ณ์
    var string: String?

    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // โ ์ ๋ฌ๋ ๋ฐ์ดํฐ ํ์ธ
        if let string = string {
            print(string)
        }
    }
}
```

# Advanced

[๊ฐ๋จํ ์์ ๋ก ์ดํด๋ณด๋ iOS Design/Architecture Pattern: Coordinator - Advanced](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_advanced/)

์ด๋ฒ ์ค์ต ์ญ์ ์์ ๊ธ์ ์ฐธ๊ณ ํ๋ค.

## ๐ parent coordinator & child coordinator

Basic ์์๋ ํ๊ฐ์ Coordinator ๋ง ์ฌ์ฉํ์๋ค. ๊ทธ๋ฌ๋ค๊ฐ โ์ฉ๋๋ณ๋ก, ํ๋ฉด๋ณ๋ก Coordinator ๋ฅผ ์ฌ๋ฌ๊ฐ ๋๊ณ  ์ฌ์ฉํ  ์๋ ์์๊น?โ ๋ผ๋ ์๊ฐ์์ ์ถ๋ฐํ ๊ฐ๋์ด parent coordinator ์ child coordinator ์ด๋ค.

<img width="700" alt="2" src="https://user-images.githubusercontent.com/69136340/130352611-e4b4f2a5-211d-43e1-998b-f62ae3b384ac.png">

๋๊ฐ ์ด์์ coordinator ๋ฅผ ์ฌ์ฉํ  ๋ ์์ ์ด๋ฏธ์ง์ฒ๋ผ parent ์ child coordinator ์ ๊ด๊ณ๋ฅผ ๋งบ์ด์ ์ฌ์ฉํ  ์ ์๋ค. ๊ธฐ์กด์ ํ๋ก์ ํธ๋ฅผ ๋ฆฌํํ ๋งํ๋ฉด์ ์งํํด๋ณด์.

## ๐ Child Coordinator ์์ฑ

- LeftCoordinator.swift

MainCoorodinator ์ child coordinator ์ญํ 

```swift
import Foundation
import UIKit

class LeftCoordinator: Coordinator {
    // โ Coordinator ํ๋กํ ์ฝ์ ์ฑํํด์ ๊ทธ๋๋ก ๊ตฌํํ ๋ชจ์ต
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController

    // โ retain cycle์ ํผํ๊ธฐ ์ํด weak ์ฐธ์กฐ๋ก ์ ์ธํด์ฃผ์ธ์.
    weak var parentCoordinator: MainCoordinator?

    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    func start() {
        // โ MainCoordinator ์ pushToLeftVC() ํจ์ ๊ตฌํ๋ถ๋ถ์ ์ฎ๊ธด๋ค
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

    // โ LeftViewController ์์๋ LeftCoordinator ๋ฅผ ์ฌ์ฉํ  ๊ฒ์ด๊ธฐ ๋๋ฌธ์ coordinator ๋ณ์ํ์์ LeftCoordinator ๋ก ๋ณ๊ฒฝ 
    weak var coordinator: LeftCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```

## ๐ Parent Coordinator ์์ Child Coordinator ๊ฐ ๊ด๊ณ๋ฅผ ๋งบ์ด์ค๋ค.

- MainCoordinator.swift

```swift
class MainCoordinator: Coordinator {
    
// ...
    
// โ ์ด์  ๊ณผ์ ์์ ์ฐ๋ฆฌ๋ LeftCoordinator ๋ก ์ด ๊ตฌํ ๋ถ๋ถ์ ์ฎ๊ฒผ๋ค.
//    func pushToLeftVC(string: String) {
//        let vc = LeftViewController.instantiate()
//        vc.coordinator = self
//        vc.string = string
//        nav.pushViewController(vc, animated: true)
//    }
    
    // โ parent ์ child coordinator ๊ด๊ณ ์ค์ 
    func leftSubscriptions() {
        let child = LeftCoordinator(navigationController: nav)
        
        // โ LeftCoordinator ์ parent coordinator ๋ก MainCoordinator ์ค์ 
        child.parentCoordinator = self
        
        // โ child coordinator ์ ์ ์ฅํ๋ ๋ฐฐ์ด์ ์ ์ฅ
        childCoordinators.append(child)
        
        // โ LeftViewController ๋ก ํ๋ฉด์ ํ
        child.start()
    }

// ...

}
```

## ๐ push ํ๋ฉด์ ํ์ ํด๋ณด์

```swift
class ViewController: UIViewController, Storyboarded {

// ...
    
    @IBAction func pushToLeftVC(_ sender: Any) {
//        self.coordinator?.pushToLeftVC(string: "left")
        // โ ๋ค์์ ์ฝ๋๋ก ๋ฐ๊ฟ์ ํธ์ถ
        self.coordinator?.leftSubscriptions()
    }

// ...
}
```

## ๐ Child Coordinator ์ ์ผ์ด ๋๋ฌ์ ๋

LeftViewController ์์ MainViewController ๋ก pop ํ ๋ ์ด๋ป๊ฒ ํด์ผํ ๊น?(pop ๋์์์ฒด๋ navigationbar ์ back button ์ด ํด์ค๋ค.)

parent coordinator ์๊ฒ ์๋ฆฌ๊ณ  child coordinator ๋ฅผ ์ง์์ผํ๋ค.

- MainCoordinator.swift

```swift
class MainCoordinator: Coordinator {

    // โ child coordinator ๋ฐฐ์ด์์ ์ง์์ผ ํ  coordinator ๋ฅผ ์ฐพ์์ ์ ๊ฑฐํ๋ ๋ฉ์๋
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {

            // โ === ์ฐ์ฐ์๋ ํด๋์ค์ ๋ ์ธ์คํด์ค๊ฐ ๋์ผํ ๋ฉ๋ชจ๋ฆฌ๋ฅผ ๊ฐ๋ฆฌํค๋์ง์ ๋ํ ์ฐ์ฐ(๊ทธ๋์ === ์ฐ์ฐ์๋ฅผ ์ฌ์ฉํ๊ธฐ ์ํด์ Coordinator ๋ฅผ ํด๋ ์ค ์ ์ฉ ํ๋กํ ์ฝ(class-only protocol) ๋ก ๋ง๋ค์ด์ค๋ค.)
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
```

- Coordinator.swift

`===` ์ฐ์ฐ์๋ฅผ ์ฌ์ฉํ๊ธฐ ์ํด์ Coordinator ๋ฅผ ํด๋ ์ค ์ ์ฉ ํ๋กํ ์ฝ(class-only protocol) ๋ก ๋ง๋ค์ด์ค๋ค.

```swift
protocol Coordinator: AnyObject {

// ...

}
```

## ๐ ๊ทธ๋ ๋ค๋ฉด ์ธ์  child coordinator ๋ฅผ ์ง์ฐ๋ ๋ฉ์๋๋ฅผ ํธ์ถํ ๊น?

๋ฐ๋ก ํ๋ฉด์ด ์ฌ๋ผ์ง ๋ ํธ์ถํ๋ฉด ๋๋ค. ํ๋ฉด์ด ์ฌ๋ผ์ง ์์ ์ ์ด ์์์ ํ๊ธฐ ์ํด์๋ ViewController์ `viewDidDisappear()` ๋ฉ์๋๋ Navigation Controller Delegate์ `didShow()` ๋ฉ์๋์์ ์ ๋ฉ์๋๋ฅผ ํธ์ถํ๋ฉด ๋๋ค.

๋ค์ ๋ ๊ฐ์ง ๋ฐฉ๋ฒ์ ์๊ฐํ๊ฒ ๋ค.

### 1๏ธโฃ ์ฒซ๋ฒ์งธ: UIViewController์ viewDidDisappear() ์ฌ์ฉ

child coordinator ์ ํ  ์ผ์ด ๋๋ฌ๋ค๋๊ฑธ parent coordinator ์๊ฒ ์๋ฆฌ๊ธฐ ์ํด์ UIViewController ์ ๋ผ์ดํ์ฌ์ดํด ๋ฉ์๋๋ฅผ ์ฌ์ฉํ๋ค.

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

ํ๋ฉด์ด ์ฌ๋ผ์ง๋ ์์ ์ธ viewDidDisappear() ์์ ํธ์ถํด์ค๋ค.

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

### 2๏ธโฃ ๋๋ฒ์งธ: UINavigationControllerDelegate์ didShow() ์ฌ์ฉ

โ๏ธ์ด ๋ฐฉ๋ฒ์์๋ viewDidDisappear()๋ฅผ ์ฌ์ฉํ์ง ์๋๋ค.
MainCoordinator ๊ฐ Navigation Controller์ ์ํธ์์ฉ์ ๋ฐ๋ก ๊ฐ์งํ  ์ ์๊ธฐ ๋๋ฌธ์ด๋ผ๊ณ  ํ๋ค.
coordinator๊ฐ ๊ด๋ฆฌํ๋ ViewController๊ฐ ๋ง์์๋ก coordinator ์คํ์ ํผ๋์ด ์ค๋ ๊ฑธ ํผํ๊ธฐ ์ํด Navigation Controller Delegate๋ฅผ ์ฑํํ๋ ๋ฐฉ๋ฒ์ ์ถ์ฒํ๋ค๊ณ  ํ๋ค.

- MainCoordinator.swift

MainCoordinator ํด๋์ค์ NSObject๋ฅผ ์์ํ๊ณ  UINavigationControllerDelegate ๋ฅผ ์ฑํํด์ค๋๋ค.

```swift
// โ NSObject ์์
class MainCoordinator: NSObject, Coordinator {
    
    // ...

    var nav: UINavigationController
    
    // ...

    func start() {
        let vc = ViewController.instantiate()
        vc.coordinator = self

        // โ nav ์ delegate ๋ฅผ self ๋ก ์ค์ 
        nav.delegate = self
        nav.pushViewController(vc, animated: false)
    }

    // ...

}

// โ UINavigationControllerDelegate ์ฑํ ๋ฐ didShow() ๋ฉ์๋ ๊ตฌํ
extension MainCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        // ์ด๋ ์  ViewController
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
           return
        }

        // fromViewController๊ฐ navigationController์ viewControllers์ ํฌํจ๋์ด์์ผ๋ฉด return. ์๋ํ๋ฉด ์ฌ๊ธฐ์ ํฌํจ๋์ด์์ง ์์์ผ ํ์ฌ fromViewController ๊ฐ ์ฌ๋ผ์ง ํ๋ฉด์ ์๋ฏธ.
        if navigationController.viewControllers.contains(fromViewController) {
           return
        }

        // child coordinator ๊ฐ ์ผ์ ๋๋๋ค๊ณ  ์๋ฆผ.
        if let leftVC = fromViewController as? LeftViewController {
           childDidFinish(leftVC.coordinator)
        }
    }
}

```

โ [didShow()](https://developer.apple.com/documentation/uikit/uinavigationcontrollerdelegate/1621848-navigationcontroller)

: navigation controller ๊ฐ view controller ์ ๋ทฐ์ navigation item properties ๋ฅผ ๋ณด์ฌ์ค ํ ํธ์ถ๋๋ค.

## ๐ ์ปค์คํ ๋ค๋ก๊ฐ๊ธฐ ๋ฒํผ์ ๋ง๋  ๊ฒฝ์ฐ๋?

์ฐ๋ฆฌ๊ฐ ์ฐ๋๋๋ก `popViewController(animated:)` ๋ฉ์๋๋ฅผ ์ฌ์ฉํ๋ฉด ๋๋ค. ์ด ๋ฉ์๋๋ฅผ ์ฌ์ฉํ๋ฉด navigation bar์ ์๋ back ๋ฒํผ( < )์ ๋๋ ์ ๋์ ๋์ผํ๊ฒ `didShow()` ์ `childDidFinish()`  ๊ฐ ํธ์ถ๋ฉ๋๋ค.

- LeftViewController.swift

```swift
class LeftViewController: UIViewController, Storyboarded {

    // ...
    
    @IBAction func popToMain(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
```

## ๐ child coordinators ๊ฐ ์ ๋๋ก ๋น์์ง๋์ง ์ดํด๋ณด์

breakpoint ๋ฅผ ์ฃผ์ด์ ์ ๊ฑฐ๋น์์ childCoordinators ๋ฐฐ์ด์ ์ถ๋ ฅํด๋ณด์๋ค.

<img width="700" alt="1" src="https://user-images.githubusercontent.com/69136340/130352626-57fc7f56-69a0-4644-8b37-78a441063703.png">

## ๐ ๋๋์ 

๊ตณ์ด coordinator ํจํด์ ์ฌ์ฉํด์ ํ๋ฉด์ ํ์ ํด์ผํ ๊น ์ถ์๋ค. pop ์ ๊ทธ๋๋ก ์ฌ์ฉํ๊ณ  push ๋ง ์ค์ ํด์ฃผ๋ ๊ฒ์ธ๋ฐ ์คํ๋ ค ์ ๊ฒฝ์ธ๊ฒ ๋์๊ณ  ์ด๊ธฐ ์ค์ ์ ์ฅ๋ฒฝ์ด ๋์ ๋๋์ด์๋ค. ํ์ง๋ง 

โ๏ธ์ ๋ง ํ๋ฉด์ ํ์ ๋ทฐ์ปจํธ๋กค๋ฌ์์ ๋ถ๋ฆฌ์์ผ์ massive ํ ๋ทฐ์ปจํธ๋กค๋ฌ๋ฅผ ํผํ๊ณ  ์ถ์ ๊ฒฝ์ฐ ์ฌ์ฉํ๊ธฐ ์ข๋ค๊ณ  ์๊ฐํ๋ค.

โ๏ธํ๋ฉด์ด ๋ง์์ง์๋ก ๋ทฐ์ปจํธ๋กค๋ฌ์ ํ๋ฉด์ ์ ํํ๋ ์ฝ๋๊ฐ ํฉ์ด์ ธ์์ด์ ํ์, ๊ด๋ฆฌํ๊ธฐ ์ด๋ ค์ด ๊ฒฝ์ฐ์ ์ฌ์ฉํ๊ธฐ ์ข๋ค๊ณ  ์๊ฐํ๋ค.

์์ ๋๊ฐ์ง ๊ฒฝ์ฐ์ ๋ํด์๋ ์ฅ์ ์ด ์์๋ค. ํ์ง๋ง ํ์ํ ๋ ์ฌ์ฉํ์ง ์์ผ๋ฉด ์ค๋ฒ์คํ์ด๋ผ๊ณ  ์๊ฐํ๋ค ๋ง๊ทธ๋๋ก ๋์์ธํจํด์ ๋งน์ ํ๋ฉด ์๋๋ค๊ณ  ๋๊ผ๋ค.

์ถ์ฒ : 

[๊ฐ๋จํ ์์ ๋ก ์ดํด๋ณด๋ iOS Design/Architecture Pattern: Coordinator - Advanced](https://lena-chamna.netlify.app/post/ios_design_pattern_coordinator_advanced/)
