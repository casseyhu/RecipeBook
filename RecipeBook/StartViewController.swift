//
//  StartViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 8/28/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }
    }
    

}
