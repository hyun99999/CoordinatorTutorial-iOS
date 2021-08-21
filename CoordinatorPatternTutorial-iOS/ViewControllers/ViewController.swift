//
//  ViewController.swift
//  CoordinatorPatternTutorial-iOS
//
//  Created by kimhyungyu on 2021/08/21.
//

import UIKit

class ViewController: UIViewController, Storyboarded {

    // MainCoorinator 추가
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushToLeftVC(_ sender: Any) {
        self.coordinator?.pushToLeftVC(string: "left")
    }
    @IBAction func pushToRightVC(_ sender: Any) {
        self.coordinator?.pushToRightVC()
    }
}

