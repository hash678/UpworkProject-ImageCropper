//
//  ImageCropper.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 05/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImageCropper:NSObject {

    static let shared = ImageCropper()

    private override init(){}

}

//MARK: Splitting
extension ImageCropper{

    
    /// Crops images into slices
    /// - Parameters:
    ///   - image: The UIImage that needs to be cropped
    ///   - imageCount: Total number of slices to be cropped into. Needs to be a perfect square number eg 4,9,16
    func cropImage(image orientedImage:UIImage, splitInto imageCount:Int, completion:@escaping (Bool) -> Void){
        
        
       
        var croppedImages = [UIImage]()
        
        let rowColumnCount = Int(sqrt(Double(imageCount)))
        
      
        
        let image = orientedImage.fixOrientation()
       guard let cgImage = image.cgImage else{return}
      
     
          let imageWidth = cgImage.width
          let imageHeight = cgImage.height
        
          
          let pieceWidth = imageWidth/(rowColumnCount)
          let pieceHeight = imageHeight/(rowColumnCount)
          
          
          var currentYPos:CGFloat = 0
          for _ in 1...rowColumnCount{
              var currentXPos:CGFloat = 0
              
              for _ in 1...rowColumnCount{
                
                

                if let image = self.cropSlice(image: image, cropArea: CGRect(x: currentXPos, y: currentYPos , width: CGFloat(pieceWidth), height: CGFloat(pieceHeight))){
                    croppedImages.append(image)
                }

                  
                
                currentXPos += CGFloat(pieceWidth)
                print("Hello")
                
               
              }
              
            currentYPos += CGFloat(pieceHeight)
          }

        saveAllCroppedImages(images: croppedImages,completion: completion)
    }
    
    
    /// Save UIImages in an ordered manner using a Queue
    /// - Parameter images: An array of UIImage
    fileprivate func saveAllCroppedImages(images:[UIImage], completion:@escaping (Bool) -> Void){
        let queue = OperationQueue()
        queue.name = Bundle.main.bundleIdentifier! + ".imagesave"
        queue.maxConcurrentOperationCount = 1

        let operations = images.map {
            return ImageSaveOperation(image: $0) { error in
                if let error = error {
                    print(error.localizedDescription)
                    queue.cancelAllOperations()
                }
            }
        }

        let completion = BlockOperation {
            completion(true)
        }
        operations.forEach { completion.addDependency($0) }

        queue.addOperations(operations, waitUntilFinished: false)
        OperationQueue.main.addOperation(completion)
        
        
    }
          
          
      
      
      
      private func cropSlice(image:UIImage, cropArea:CGRect) -> UIImage?{
          guard let cgImage = image.cgImage?.cropping(to: cropArea) else{
            print("Invalid area \(image.size) | \(cropArea)")
            return nil}
        print("Valid area \(image.size) | \(cropArea)")
        return UIImage(cgImage: cgImage)
        
      }
//
//      private func saveImage(image:UIImage){
//            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
//        }
//
//    @objc fileprivate func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
//        print("Called")
//        guard error == nil else {
//
//        print("Error saving")
//           return
//        }
//
//     }
    
}


//MARK: Gluing
extension ImageCropper{

    
    func stitchImage(images:[PHAsset], completion:(UIImage?) -> Void){
        
        //Number of rows/columns
        let rowColumnCount = sqrt(CGFloat(images.count))
        
        //Dimensions of the final output image
        
        let finalImageWidth = CGFloat(images.first!.pixelWidth) * rowColumnCount
        let finalImageHeight = CGFloat(images.first!.pixelHeight) * rowColumnCount
        let finalImageSize = CGSize(width: finalImageWidth, height: finalImageHeight)
        

        //Create Canvas for output image
       // UIGraphicsBeginImageContextWithOptions(finalImageSize, false, 0)
        UIGraphicsBeginImageContext(finalImageSize)
        
        //Maintains current y position while drawing on canvas
        var currentYPos:CGFloat = 0
        
        for i in 0..<Int(rowColumnCount){
            
            //Calculates the max height needed for current row. (In case row heights vary)
            var maxHeight:CGFloat = 0
            
            
            //Maintains current y position while drawing on canvas
            var currentXPos:CGFloat = 0
            
            
            for j in 0..<Int(rowColumnCount){
                
                //Index of current image
                let index = (i*Int(rowColumnCount)) + j
                
                let currentImage = images[index]
                
                let currentImageHeight = CGFloat(currentImage.pixelHeight)
                let currentImageWidth = CGFloat(currentImage.pixelWidth)
                let currentImageRect = CGRect(x: currentXPos, y: currentYPos, width: currentImageWidth, height: currentImageHeight)

                
                //Updates max height of row if needed.
                maxHeight = maxHeight < currentImageHeight ? currentImageHeight : maxHeight
                print(currentImageRect)
                
                //Draw PHAsset on canvas.
                if !drawPHAsset(asset: currentImage, inRect: currentImageRect){
                    completion(nil)
                    return
                }
                
            
                currentXPos += currentImageWidth
            }
            currentYPos += maxHeight
        }
        
        
        let outputImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        completion(outputImage)
       // saveImage(image: outputImage)
    }
    
    
    fileprivate func drawPHAsset(asset currentImage:PHAsset, inRect currentImageRect:CGRect) -> Bool{
        

        var uiImage:UIImage?
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true

        manager.requestImage(for: currentImage, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { (image, info) in
            uiImage = image

        }
        if uiImage == nil{
           return false
        }
        uiImage!.draw(in: currentImageRect, blendMode: .normal, alpha: 1)
        return true
    }
    
}





