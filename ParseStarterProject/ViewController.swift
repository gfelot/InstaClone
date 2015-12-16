/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUpOutlet: UIButton!
    
    @IBOutlet weak var loginOutlet: UIButton!
    
    @IBOutlet weak var labelOutlet: UILabel!
    
    var activityIndicator = UIActivityIndicatorView()
    
    var signUpActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            print(PFUser.currentUser())
            self.performSegueWithIdentifier("login", sender: self)
        }
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        guard userName.text != "" && password.text != "" else {
            alertPopUp("Error in Form", message: "Please enter a username AND a password")
            return
        }
        waitingIndicator()
        if signUpActive == true {
            tryToSignUp()
        } else {
            tryToLogin()
        }
        
    }
    
    @IBAction func login(sender: AnyObject) {
        if signUpActive == true {
            signUpOutlet.setTitle("Login", forState: UIControlState.Normal)
            labelOutlet.text = "Not Registred ?"
            loginOutlet.setTitle("Sign Up", forState: .Normal)
            signUpActive = false
        } else {
            signUpOutlet.setTitle("Sign Up", forState: UIControlState.Normal)
            labelOutlet.text = "Already Registred ?"
            loginOutlet.setTitle("Login", forState: .Normal)
            signUpActive = true
        }
    }
    
    func tryToSignUp() {
        var errorMessage = "Please try again later"
        let user = PFUser()
        user.username = userName.text
        user.password = password.text
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            guard error == nil else {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                self.alertPopUp("Failed Sign Up", message: errorMessage)
                return
            }
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    func tryToLogin() {
        var errorMessage = "Please try again later"
        PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!) { (user, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            guard user != nil else {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                self.alertPopUp("Failed Login", message: errorMessage)
                return
            }
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    func waitingIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func alertPopUp(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
