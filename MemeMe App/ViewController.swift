//
//  ViewController.swift
//  MemeMe App
//
//  Created by Mawhiba Al-Jishi on 05/08/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    struct Meme {
        var topText: String?
        var bottomText: String?
        var originalImage: UIImage?
        var memedImage: UIImage?
        
    }
    
    @IBOutlet var imageViewPicker: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var shareButton: UIBarButtonItem!
    var counterTop = 0
    var counterBottom = 0
    var memedImage = UIImage()
    
    let pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        pickerController.delegate = self
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        setupTextFieldStyle(toTextField: topTextField)
        setupTextFieldStyle(toTextField: bottomTextField)
//        topTextField.delegate = self
//        bottomTextField.delegate = self
//        topTextField.defaultTextAttributes = memeTextAttributes
//        bottomTextField.defaultTextAttributes = memeTextAttributes
//        topTextField.textAlignment = .center
//        bottomTextField.textAlignment = .center
    
    }
    
    //MARK: Keyboard Adjustments (Show - Hide)
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        print(keyboardSize.cgRectValue.height)
        return keyboardSize.cgRectValue.height
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    //MARK: Pick an image from Album
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickerController.sourceType = .photoLibrary
        openImagePicker(pickerController.sourceType)
    }
    
    //MARK: Pick an image from Camera
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickerController.sourceType = .camera
        openImagePicker(pickerController.sourceType)
    }
    
    func openImagePicker(_ type: UIImagePickerController.SourceType) {
        pickerController.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            pickerController.cameraCaptureMode = .photo
            pickerController.modalPresentationStyle = .fullScreen
            present(pickerController,animated: true,completion: nil)
            
        }
        else {
            pickerController.allowsEditing = true
            pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            present(pickerController,animated: true,completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageViewPicker.contentMode = .scaleAspectFit
            imageViewPicker.image = pickedImage
            dismiss(animated: true, completion: nil)
        }
        shareButton.isEnabled = true
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Clear the textField first click
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if topTextField.isEditing {
            if counterTop == 0 {
                topTextField.text = ""
                counterTop += 1
            }
            else {
                return
            }
        }
        else if bottomTextField.isEditing {
            if counterBottom == 0 {
                bottomTextField.text = ""
                counterBottom += 1
            }
        }
    }

    //MARK: Formatting the textField contetn
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
        
    ]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    func setupTextFieldStyle(toTextField textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    //MARK: Share a memed image:
    @IBAction func shareMeme(_ sender: Any) {
        memedImage = generateMemedImage()

        //Define an instance of the ActivityViewController
        let ac = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(ac, animated: true)
        ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                return
            }
        }
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewPicker.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        hideToolbars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        hideToolbars(false)
        return memedImage
    }
    
    func hideToolbars(_ hide: Bool) {
        toolBar.isHidden = hide
        navBar.isHidden = hide
    }
}
