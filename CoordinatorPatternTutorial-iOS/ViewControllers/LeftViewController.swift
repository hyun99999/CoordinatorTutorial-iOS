//
//  LeftViewController.swift
//  CoordinatorPatternTutorial-iOS
//
//  Created by kimhyungyu on 2021/08/21.
//

import UIKit

class LeftViewController: UIViewController, Storyboarded {

    weak var coordinator: LeftCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        coordinator?.didFinishLeft()
//    }
    
    @IBAction func popToMain(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
