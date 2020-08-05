//
//  LoginViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 8/4/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    
    @IBOutlet weak var loginbutton: UIButton!
    @IBOutlet weak var errorlabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorlabel.text = ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func loginTapped(_ sender: Any) {
        if usernametxt.text! == "" || passwordtxt.text! == "" {
            errorlabel.text = "Please fill in all fields"
            return
        }
        
        let uname = usernametxt.text!
        let pass = passwordtxt.text!
        
        Auth.auth().signIn(withEmail: uname, password: pass) { (result, error) in
            if error != nil {
                self.errorlabel.text = "Could not login, please try again"
            }
            else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
                self.view.window?.rootViewController = vc
                self.view.window?.makeKeyAndVisible()
            }
        }
        
        
    }
    
}
