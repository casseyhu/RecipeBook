//
//  TitleViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 8/4/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import FirebaseUI


class TitleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    @IBAction func loginTapped(_ sender: UIButton) {
//        let authUI = FUIAuth.defaultAuthUI()
//        guard authUI != nil else {
//            return
//        }
//        authUI?.delegate = self
//        let authVC = authUI!.authViewController()
//        present(authVC, animated: true, completion: nil)
//    }
    
}


//extension TitleViewController: FUIAuthDelegate {
//    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        if error != nil {
//            return
//        }
//        performSegue(withIdentifier: "successlogin", sender: self)
//        
//        
//    }
//}
