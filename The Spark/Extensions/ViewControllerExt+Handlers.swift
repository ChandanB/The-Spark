//
//  LoginController+handlers.swift
//  It's Lit
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleFacebookRegister(email: String, name: String, profileImageUrl: String, uid: String, gender: String) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl, "id": uid, "gender": gender]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
            self.user = User(dictionary: values as [String : AnyObject])
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
            let user = User(dictionary: values)
            //may crash if keys don't match
            user.setValuesForKeys(values)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //       var selectedImageFromPicker: UIImage?
        //
        //        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
        //            selectedImageFromPicker = editedImage
        //        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
        //            selectedImageFromPicker = originalImage
        //        }
        
        //        if let selectedImage = selectedImageFromPicker {
        //            profileImageView.image = selectedImage
        //        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
