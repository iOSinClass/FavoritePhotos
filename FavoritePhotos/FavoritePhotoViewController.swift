//
//  FavoritePhotoViewController.swift
//  FavoritePhotos
//
//  Created by CSSE Department on 4/30/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class FavoritePhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    
    var storageRef: StorageReference!
    
    @IBAction func takePhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true)
    }
    
    func uploadImage(_ data: Data?) {
        guard let data = data else { return }
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        progress.isHidden = false
        progress.progress = 0
        
        let uploadTask = storageRef.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if let error = error {
                print("Error with upload \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(StorageTaskStatus.progress) { (snapshot) in
            guard let progress = snapshot.progress else { return }
            self.progress.progress = Float(progress.fractionCompleted)
        }
        
        uploadTask.observe(StorageTaskStatus.success) { (snapshot) in
            print("Your upload is finished")
            self.progress.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference(withPath: "favorite")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FavoritePhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.imageView.image = image // This is a cheat
            uploadImage(UIImageJPEGRepresentation(image, 0.5))
        }
        picker.dismiss(animated: true)
    }
}
