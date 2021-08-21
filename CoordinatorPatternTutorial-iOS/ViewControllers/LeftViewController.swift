//
//  LeftViewController.swift
//  CoordinatorPatternTutorial-iOS
//
//  Created by kimhyungyu on 2021/08/21.
//

import UIKit

class LeftViewController: UIViewController, Storyboarded {
    var string: String?
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let string = string {
            print(string)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
