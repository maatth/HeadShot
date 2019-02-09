//
//  FaceDetailViewController.swift
//  HeadShot
//
//  Created by Maat on 23/06/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import UIKit
import os.log

class FaceDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photo1ImageView: UIImageView!
    @IBOutlet weak var photo2ImageView: UIImageView!
    @IBOutlet weak var photo3ImageView: UIImageView!
    @IBOutlet weak var photo4ImageView: UIImageView!
    @IBOutlet weak var isEnemySwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var face: Face?
    var currentTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.815686, green: 0.941176, blue: 1.0, alpha: 1.0) //sky blue
        
        nameTextField.delegate = self
        
        if let face = face {
            navigationItem.title = face.name
            nameTextField.text = face.name
            photo1ImageView.image = face.photo1
            photo2ImageView.image = face.photo2
            photo3ImageView.image = face.photo3
            photo4ImageView.image = face.photo4
            isEnemySwitch.setOn(face.isEnemy, animated: false)
        }
        
        photo1ImageView.tag = 1
        photo2ImageView.tag = 2
        photo3ImageView.tag = 3
        photo4ImageView.tag = 4

        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        checkValidMealName()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: image picker
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // let's use the original
        guard let selectedImageOld = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let selectedImageResized = selectedImageOld.resizedImage(newSize: CGSize(width: 180, height: 240))
        let selectedImage = selectedImageResized.circle
        
        
        if currentTag == 1 {
            photo1ImageView.image = selectedImage
        } else if currentTag == 2 {
            photo2ImageView.image = selectedImage
        } else if currentTag == 3 {
            photo3ImageView.image = selectedImage
        } else if currentTag == 4 {
            photo4ImageView.image = selectedImage
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
 

    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo1 = photo1ImageView.image
        let photo2 = photo2ImageView.image
        let photo3 = photo3ImageView.image
        let photo4 = photo4ImageView.image
        let isEnemy = isEnemySwitch.isOn
        let life = 2
        
        // Set the face to be passed to FaceTableViewController after the unwind segue.
        face = Face(name: name, photo1: photo1, photo2: photo2, photo3: photo3, photo4: photo4, isEnemy: isEnemy, life: life)
        
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        currentTag = (sender.view?.tag)!
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

}
