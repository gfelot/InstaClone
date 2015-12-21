//
//  PostImageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Gil Felot on 19/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    
    func waitingIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func alertPopUp(title:String, message:String) {
        let popUP = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        popUP.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(popUP, animated: true, completion: nil)
    }
    
//    func chooseLibrary(title:String, message:String) {
//        
//        let image = UIImagePickerController()
//        image.delegate = self
//        
//        let popUP = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let photoPick = UIAlertAction(title: "Photo", style: .Default) { (action) -> Void in
//            image.sourceType = UIImagePickerControllerSourceType.Camera
//            self.dismissViewControllerAnimated(true, completion: nil)
//            self.presentViewController(image, animated: true, completion: nil)
//        }
//        
//        let albumPick = UIAlertAction(title: "Album", style: .Default) { (action) -> Void in
//            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            image.allowsEditing = false
//            self.dismissViewControllerAnimated(true, completion: nil)
//            self.presentViewController(image, animated: true, completion: nil)
//            
//        }
//        popUP.addAction(photoPick)
//        popUP.addAction(albumPick)
//
//        self.presentViewController(popUP, animated: true, completion: nil)
//    }

    
    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBAction func chooseImage(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
//        chooseLibrary("Take a pics or select one ?", message: "Great power requier great responsability")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
    }
    
    @IBOutlet weak var message: UITextField!
    
    @IBAction func postImage(sender: AnyObject) {
        waitingIndicator()
        let post = PFObject(className: "Post")
        post["message"] = message.text
        post["userID"] = PFUser.currentUser()!.objectId!
//        let imageData = UIImagePNGRepresentation(imageToPost.image!)
        let imageData =  UIImageJPEGRepresentation(imageToPost.image!, 0.5)
        let imageFile = PFFile(name: "image.png", data: imageData!)
        post["imageFile"] = imageFile
        post.saveInBackgroundWithBlock { (success, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            guard error == nil else {
                print(error)
                self.alertPopUp("Oh Oh !?!", message: "Something Wrong Happend...")
                return
            }
            self.imageToPost.image = UIImage(named: "iu.png")
            self.message.text = ""
            self.alertPopUp("Image Send", message: "Are you happy with that ?")
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
    


}
