//
//  MainCoordinator.swift
//  CoordinatorPatternTutorial-iOS
//
//  Created by kimhyungyu on 2021/08/21.
//

import Foundation
import UIKit

class MainCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    // 앱이 보여질 때 처음 화면
    func start() {
        let vc = ViewController.instantiate()
        vc.coordinator = self
        nav.delegate = self
        nav.pushViewController(vc, animated: false)
    }
    
    // 추가 화면 전환
//    func pushToLeftVC(string: String) {
//        let vc = LeftViewController.instantiate()
//        vc.coordinator = self
//        vc.string = string
//        // push 되는 애니메이션 여부 true 설정
//        nav.pushViewController(vc, animated: true)
//    }
    
    func leftSubscriptions() {
        let child = LeftCoordinator(navigationController: nav)
        
        // LeftCoordinator 의 parent coordinator 로 MainCoordinator 설정
        child.parentCoordinator = self
        
        // child coordinator 을 저장하는 배열에 저장
        childCoordinators.append(child)
        
        // LeftViewController 로 화면전환
        child.start()
    }
    
    func pushToRightVC() {
        let vc = RightViewController.instantiate()
        vc.coordinator = self
        // push 되는 애니메이션 여부 true 설정
        nav.pushViewController(vc, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

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
