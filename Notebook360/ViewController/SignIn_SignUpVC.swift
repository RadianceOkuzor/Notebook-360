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
    
    @IBOutlet weak var signupBtn: UIButton!
    
    var signUpPressed = true
    
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
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        if !self.firstNameField.isHidden {
            emailField.text = ""
            self.firstNameField.isHidden = true ; self.firstNameField.text = ""
            self.lastNameField.isHidden = true ; lastNameField.text = ""
            self.confPasswordField.isHidden = true ; confPasswordField.text = "" ; passwordField.text = ""
            
            self.signupBtn.setTitle("Sign Up", for: .normal)
            return
        }
        
        if let em = emailField.text, let pass = passwordField.text, (em.isEmpty == false || pass.isEmpty == false) {
            pageVM.signInPressed(em: em, pass: pass) {pass, msg in
                if pass {
                    self.performSegue(withIdentifier: "showHomeFromSignIn", sender: nil)
                } else {
                    self.pageVM.showAlert(vc: self, msg: "Error Login in", msgBody: msg) {
                        //
                    }
                }
            }
        } else {
            pageVM.showAlert(vc: self, msg: "Empty Field", msgBody: "ensure both the email and password are not empty") {
                //
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        self.firstNameField.isHidden = false
        self.lastNameField.isHidden = false
        self.confPasswordField.isHidden = false
        
        if let em = emailField.text, let pass = passwordField.text,
           let conPass = confPasswordField.text,
           let firstName = firstNameField.text,
           let lastName = lastNameField.text,
           !em.isEmpty && !pass.isEmpty && !conPass.isEmpty && !firstName.isEmpty && !lastName.isEmpty
            {
            pageVM.signUpPressed(em: em, pass: pass, conPass: conPass, firstName: firstName, lastName: lastName) {pass,msg in
                // perform segue
                if pass {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showHomeFromSignIn", sender: nil)
                    }
                } else {
                    self.pageVM.showAlert(vc: self, msg: "Error Login in", msgBody: msg) {
                        //
                    }
                }
            }
        } else {
            if signupBtn.titleLabel?.text == "Register" {
                showAlert(title: "Missing Field", msg: "would you like to register or sign up")
            }
        }
        
        signupBtn.setTitle("Register", for: .normal)
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let signIn = UIAlertAction(title: "sign in", style: .default) { _ in
            self.firstNameField.isHidden = true
            self.lastNameField.isHidden = true
            self.confPasswordField.isHidden = true
            
            self.signupBtn.setTitle("Sign Up", for: .normal)
        }
        
        let signUp = UIAlertAction(title: "sign up", style: .default) { _ in
            self.firstNameField.isHidden = false
            self.lastNameField.isHidden = false
            self.confPasswordField.isHidden = false
        }
        
        alert.addAction(signIn)
        alert.addAction(signUp)
        
        present(alert, animated: true)
    }
}
