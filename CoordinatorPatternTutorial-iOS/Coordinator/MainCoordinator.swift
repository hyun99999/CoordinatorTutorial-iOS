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
        nav.pushViewController(vc, animated: false)
    }
    
    // 추가 화면 전환
    func pushToLeftVC(string: String) {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self
        vc.string = string
        // push 되는 애니메이션 여부 true 설정
        nav.pushViewController(vc, animated: true)
    }
    
    func pushToRightVC() {
        let vc = RightViewController.instantiate()
        vc.coordinator = self
        // push 되는 애니메이션 여부 true 설정
        nav.pushViewController(vc, animated: true)
    }
}
