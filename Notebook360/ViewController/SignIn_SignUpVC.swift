//
//  SignIn_SignUpVC.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import Firebase
import FirebaseAuth
import KCLoginSDK

class SignIn_SignUpVC: UIViewController { 
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confPasswordField: UITextField!
    @IBOutlet weak var kcPressed: KCLoginButton!
    
    var signUpPressed = false
    
    var pageVM: PageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageVM = PageViewModel()
        
        if pageVM.isUserLogedIn() {
            // present home screen
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showHomeFromSignIn", sender: self)
            }
            
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        if let em = emailField.text, let pass = passwordField.text, (em.isEmpty == false && pass.isEmpty == false) {
            pageVM.signInPressed(em: em, pass: pass) {
                self.performSegue(withIdentifier: "showHomeFromSignIn", sender: nil)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        signUpPressed.toggle()
        firstNameField.isHidden = signUpPressed
        lastNameField.isHidden = signUpPressed
        confPasswordField.isHidden = signUpPressed
        
        if let em = emailField.text, let pass = passwordField.text,
           let conPass = confPasswordField.text,
           let firstName = firstNameField.text,
           let lastName = lastNameField.text,
           !em.isEmpty && !pass.isEmpty && !conPass.isEmpty && !firstName.isEmpty && !lastName.isEmpty
            {
            pageVM.signUpPressed(em: em, pass: pass, conPass: conPass, firstName: firstName, lastName: lastName) {
                // perform segue
                self.performSegue(withIdentifier: "showHomeFromSignIn", sender: nil)
            }
        }
    }
}
