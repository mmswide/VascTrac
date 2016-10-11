//
//  UserViewController.swift
//  Vasctrac
//
//  Created by Developer on 6/3/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var profileImageButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var profileImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserProflePicture()
    }

    private func setupUserProflePicture() {
        if let currentUser = SessionManager.sharedManager.currentUser, let profilePic = currentUser.picture {
            self.profileImage = UIImage(data: profilePic)
        }
        
        if let profileImage = profileImage {
            self.profileImageButton.setImage(profileImage, forState:.Normal)
        } else {
            self.profileImageButton.setImage(UIImage(named: "profile"), forState:.Normal)
        }
        
        profileImageButton.imageView?.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2
    }
    
    @IBAction func changeProfilePicture(sender: AnyObject) {
        
        imagePicker.editing = true
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "From Library", style: .Default, handler: { [unowned self] action in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Picture", style: .Default, handler: { [unowned self] action in
                self.imagePicker.sourceType = .Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
                }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

}

extension UserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImage = pickedImage
            self.profileImageButton.setImage(pickedImage, forState:.Normal)
            SessionManager.sharedManager.currentUser?.profilePicture(UIImagePNGRepresentation(pickedImage))
        }
        picker.delegate = nil
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.delegate = nil
        dismissViewControllerAnimated(true, completion: nil)
    }
}
