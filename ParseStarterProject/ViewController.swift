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
    
    var signUpActive : Int = 1;
    
    func displayAlert(title : String, message : String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpLoginOutlet: UIButton!
    @IBAction func signUpLoginButton(sender: AnyObject) {
        
        
        
            if usernameField.text == "" || passwordField.text == ""
            {
                displayAlert("Error in form", message: "Please enter a username and/or password")
                PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                    
                    if error == nil
                    {
                        PFUser.logOut()
                        PFUser.currentUser()?.objectId = nil
                    }
                })

            }
            else
            {
                if signUpActive == 1
                {
                    
                    usernameField.text? = (usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!
                    passwordField.text? = passwordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50));
                    activityIndicator.center = self.view.center
                    activityIndicator.hidesWhenStopped = true;
                    activityIndicator.activityIndicatorViewStyle = .Gray
                    view.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    
                    let user = PFUser();
                    user.username = usernameField.text;
                    user.password = passwordField.text;
                    
                    user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if error == nil
                        {
                            //self.displayAlert("Welcome to Photo Sharing!", message: "Sign Up Successful")
                            if PFUser.currentUser()?.objectId != nil
                            {
                                self.performSegueWithIdentifier("login", sender: self)
                            }
                        }
                        
                        else
                        {
                            if let errorString = error?.userInfo["error"] as? String
                            {
                                self.displayAlert("Error signing up", message: errorString)
                                PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                                    
                                    if error == nil
                                    {
                                        PFUser.logOut()
                                        PFUser.currentUser()?.objectId = nil
                                    }
                                })
                                
                            }
                        }
                    })
                }
                
                else if signUpActive == 0
                {
                    usernameField.text? = (usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!
                    passwordField.text? = passwordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50));
                    activityIndicator.center = self.view.center
                    activityIndicator.hidesWhenStopped = true;
                    activityIndicator.activityIndicatorViewStyle = .Gray
                    view.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    
                    PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!, block: { (user, error) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if error == nil
                        {
                            print("Login successful")
                            if PFUser.currentUser()?.objectId != nil
                            {
                                self.performSegueWithIdentifier("login", sender: self)
                            }
                        }
                        
                        else
                        {
                            if let errorString = error?.userInfo["error"] as? String
                            {
                                self.displayAlert("Failed Log in", message: errorString)
                                PFUser.currentUser()?.objectId = nil
                            }
                        }
                    })
                }
            }
        
    }
    @IBOutlet weak var registeredMessage: UILabel!
    @IBOutlet weak var loginSignUpOutlet: UIButton!
    @IBAction func loginSignUpButton(sender: AnyObject) {
        
        if signUpActive == 0
        {
            registeredMessage.text = "Already registered?"
            loginSignUpOutlet.setTitle("Log in", forState: .Normal)
            signUpLoginOutlet.setTitle("Sign Up", forState: .Normal)
            signUpActive = 1;
        }
        else if signUpActive == 1
        {
            registeredMessage.text = "Not registered?"
            loginSignUpOutlet.setTitle("Sign up", forState: .Normal)
            signUpLoginOutlet.setTitle("Log in", forState: .Normal)
            signUpActive = 0;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil
        {
            performSegueWithIdentifier("login", sender: self)
            self.navigationController?.navigationBarHidden = true
        }
        
        //
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "login"
        {
            if PFUser.currentUser()?.objectId == nil
            {
                return false
            }
            
            if usernameField.text == "" || passwordField.text == ""
            {
                return false
            }
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
