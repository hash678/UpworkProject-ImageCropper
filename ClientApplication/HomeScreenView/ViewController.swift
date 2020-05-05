//
//  ViewController.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 05/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let slices = [4,9,16]
    var splitCount = 4
    
    fileprivate let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var glueImageButton: UIImageView!
    @IBOutlet weak var splitImageButton: UIImageView!
    
    @IBOutlet weak var slicesCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitCount = UserDefaults.standard.integer(forKey: "splitCount")
        slicesCollectionView.selectItem(at: IndexPath(row: slices.firstIndex(of: splitCount) ?? 0, section: 0), animated: true, scrollPosition: .left)
        
        
        glueImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(glueImages)))
        splitImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(splitImages)))

    }

    @objc fileprivate func glueImages(){
        glueImageButton.addOnTapAnimation { (_) in
            let glueViewController = self.storyboard?.instantiateViewController(withIdentifier: "glueViewController") as! GlueViewController
            glueViewController.splitCount = self.splitCount
            self.navigationController?.pushViewController(glueViewController, animated: true)
                   
        }
       
    }
    
    @objc fileprivate func splitImages(){
        splitImageButton.addOnTapAnimation { (_) in
            self.openImagePicker()
        }
    }

}
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mySlicesCell", for: indexPath) as! SlicesCell
        
        switch indexPath.row{
        case 0: cell.imageView.image = #imageLiteral(resourceName: "Slices4Icon")
            case 1: cell.imageView.image = #imageLiteral(resourceName: "Slices9Icon")
            case 2: cell.imageView.image = #imageLiteral(resourceName: "Slices16Icon")
        default: break
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        splitCount = slices[indexPath.row]
        UserDefaults.standard.set(splitCount, forKey: "splitCount")
    }
    
    
}

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    fileprivate func openImagePicker(){
    imagePicker.delegate = self
               imagePicker.sourceType = .photoLibrary
               present(imagePicker, animated: true, completion: nil)
    }
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cropImage(image:pickedImage)
        }
     
        dismiss(animated: true, completion: nil)
    }
    
    func cropImage(image:UIImage) {
          ImageCropper.shared.cropImage(image: image, splitInto: splitCount)

      }
}




extension UIView{
    func addOnTapAnimation(completion:((Bool) -> Void)? = nil){
           self.alpha = 0.25
           UIView.animate(withDuration: 0.5, animations: { [weak self] in
               self?.alpha = 1
           }, completion: completion)
       
       }
}
