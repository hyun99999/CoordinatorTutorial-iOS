//
//  ChildCoordinator.swift
//  CoordinatorPatternTutorial-iOS
//
//  Created by kimhyungyu on 2021/08/22.
//

import Foundation
import UIKit

class LeftCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var nav: UINavigationController
    
    // retain cycle을 피하기 위해 weak 참조로 선언해주세요.
    weak var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    // 앱이 보여질 때 처음 화면
    func start() {
        let vc = LeftViewController.instantiate()
        vc.coordinator = self
        nav.pushViewController(vc, animated: true)
    }
    
//    func didFinishLeft() {
//        parentCoordinator?.childDidFinish(self)
//    }
}
