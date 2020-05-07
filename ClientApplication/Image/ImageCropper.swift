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
    func cropImage(image orientedImage:UIImage, splitInto imageCount:Int,progress:@escaping(Double)->Void, completion:@escaping (Bool) -> Void){
        
        
       
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
                }else{
                    completion(false)
                    return
                }

                  
                
                currentXPos += CGFloat(pieceWidth)
                
               
              }
              
            currentYPos += CGFloat(pieceHeight)
          }

        saveAllCroppedImages(images: croppedImages,progress: progress,completion: completion)
    }
    
    
    /// Save UIImages in an ordered manner using a Queue
    /// - Parameter images: An array of UIImage
    fileprivate func saveAllCroppedImages(images:[UIImage],progress:@escaping (Double)->Void ,completion:@escaping (Bool) -> Void){
        let queue = OperationQueue()
        queue.name = Bundle.main.bundleIdentifier! + ".imagesave"
        queue.maxConcurrentOperationCount = 1

        var failed = false
        var count = 0
        let operations = images.map {
            return ImageSaveOperation(image: $0) { error in
                
                if let error = error {
                    failed = true
                    
                    print(error.localizedDescription)
                    
                    queue.cancelAllOperations()
                    return
                }
                count += 1
                progress(Double(count)/Double(images.count))
            }
        }

      
        let completion = BlockOperation {
            completion(!failed)
        }
        operations.forEach { completion.addDependency($0) }

        queue.addOperations(operations, waitUntilFinished: false)
        //progress(queue.progress.fractionCompleted)
        
        OperationQueue.main.addOperation(completion)
        //operations.
        
        
    }
          
          
      
      
      
      fileprivate func cropSlice(image:UIImage, cropArea:CGRect) -> UIImage?{
          guard let cgImage = image.cgImage?.cropping(to: cropArea) else{
            print("Unable to crop slice. Specified CGRect is invalid")
            return nil}
        return UIImage(cgImage: cgImage)
        
      }

    
}


//MARK: Gluing
extension ImageCropper{

    
    func stitchImage(images:[PHAsset],progress:(Double) -> Void, completion:(UIImage?) -> Void){
        
        //Number of rows/columns
        let rowColumnCount = sqrt(CGFloat(images.count))
        
        //Dimensions of the final output image
        
        let finalImageWidth = CGFloat(images.first!.pixelWidth) * rowColumnCount
        let finalImageHeight = CGFloat(images.first!.pixelHeight) * rowColumnCount
        let finalImageSize = CGSize(width: finalImageWidth, height: finalImageHeight)
        

        //Create Canvas for output image
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
                
                //Current Slice data
                let currentImage = images[index]
                let currentImageHeight = CGFloat(currentImage.pixelHeight)
                let currentImageWidth = CGFloat(currentImage.pixelWidth)
                let currentImageRect = CGRect(x: currentXPos, y: currentYPos, width: currentImageWidth, height: currentImageHeight)

                
                //Updates max height of row if needed.
                maxHeight = maxHeight < currentImageHeight ? currentImageHeight : maxHeight
               // print(currentImageRect)
                
                //Draw PHAsset on canvas.
                if !drawPHAsset(asset: currentImage, inRect: currentImageRect){
                    completion(nil)
                    return
                }
                //Update progress
                progress(Double(index)/Double(images.count))
                
            
                currentXPos += currentImageWidth
            }
            currentYPos += maxHeight
        }
        
        
        let outputImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        completion(outputImage)
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





