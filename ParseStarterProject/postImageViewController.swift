//
//  postImageViewController.swift
//  Photo Sharing
//
//  Created by Swapnil Dhanwal on 26/01/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class postImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func displayAlert(title : String, message : String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    var activityIndicator = UIActivityIndicatorView()
    
   
    @IBAction func takePicture(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .Camera
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBOutlet weak var imageToPost: UIImageView!
    @IBAction func chooseImage(sender: AnyObject) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true) { () -> Void in
            
        }
    }
    @IBOutlet weak var message: UITextField!
    @IBAction func uploadImage(sender: AnyObject) {
        
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let post = PFObject(className: "post")
        post["message"] = message.text
        post["userid"] = PFUser.currentUser()?.objectId
        let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.1)
        let imageFile = PFFile(name: "image.png", data: imageData!)
        post["imageFile"] = imageFile
        post.saveInBackgroundWithBlock { (success, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error == nil
            {
                print("success")
                self.imageToPost.image = UIImage(named: "placeholder.png")
                self.displayAlert("Image Posted!", message: ":)")
                self.message.text = ""
            }
            else
            {
                self.imageToPost.image = UIImage(named: "placeholder.png")
                self.displayAlert("Image couldn't be posted", message: ":(")
                self.message.text = ""
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
