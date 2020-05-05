//
//  SplitViewController.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 05/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController:UIViewController{
    var splitCount = 4
    var image:UIImage?
    fileprivate let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       openImagePicker()
    }
    
    fileprivate func openImagePicker(){
    imagePicker.delegate = self
               imagePicker.sourceType = .photoLibrary
               present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cropImage(_ sender: Any) {
        ImageCropper.shared.cropImage(image: image!, splitInto: 4)

    }
    
}


extension SplitViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    

    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImageView.image = UIImage(cgImage: pickedImage.fixOrientation().cgImage!)
            
            
            //cropImage(image:pickedImage)
        }
     
        dismiss(animated: true, completion: nil)
    }
    
    func cropImage(image:UIImage) {
          ImageCropper.shared.cropImage(image: image, splitInto: splitCount)

      }
}


