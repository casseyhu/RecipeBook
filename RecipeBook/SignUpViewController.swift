//
//  SignUpViewController.swift
//  RecipeBook
//
//  Created by Cassey Hu on 8/4/20.
//  Copyright © 2020 Cassey Hu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var firstnametxt: UITextField!
    @IBOutlet weak var lastnametxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    
    @IBOutlet weak var signupbutton: UIButton!
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

    @IBAction func signupTapped(_ sender: Any) {
        if emailtxt.text! == "" || firstnametxt.text! == "" || lastnametxt.text! == "" || passwordtxt.text! == "" {
            errorlabel.text = "Please fill in all fields"
            return
        }
        
        let fname = firstnametxt.text!
        let lname = lastnametxt.text!
        let email = emailtxt.text!
        let pass = passwordtxt.text!
        
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
            if error == nil {
                let db = Firestore.firestore()
                let uid = result!.user.uid
                db.collection("users").document(uid).setData(["fname":fname, "lname":lname]) { (error) in
                    if error != nil {
                        self.errorlabel.text = "Error Saving User"
                    }
                }
                let settings = UserDefaults.standard
                settings.set(uid, forKey: "uid")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
                self.view.window?.rootViewController = vc
                self.view.window?.makeKeyAndVisible()
            }
            else {
                self.errorlabel.text = "Error creating user"
            }
        }

    }
}
