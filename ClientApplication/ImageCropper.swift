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

class ImageCropper {
    
    static let shared = ImageCropper()
    private init(){}

}

//MARK: Splitting
extension ImageCropper{

    
    /// Crops images into slices
    /// - Parameters:
    ///   - image: The UIImage that needs to be cropped
    ///   - imageCount: Total number of slices to be cropped into. Needs to be a perfect square number eg 4,9,16
      func cropImage(image:UIImage, splitInto imageCount:Int){
        let rowColumnCount = Int(sqrt(Double(imageCount)))
        
          let imageWidth = image.size.width
          let imageHeight = image.size.height
          
          let pieceWidth = imageWidth/CGFloat(rowColumnCount)
          let pieceHeight = imageHeight/CGFloat(rowColumnCount)
          
          
          var currentYPos:CGFloat = 0
          for _ in 1...rowColumnCount{
              var currentXPos:CGFloat = 0
              
              for _ in 1...rowColumnCount{
                  cropImage(image: image, cropArea: CGRect(x: currentXPos, y: currentYPos, width: pieceWidth, height: pieceHeight))
                  currentXPos += pieceWidth
              }
              
              currentYPos += pieceHeight
          }
          
          
          
          
      }
      
      
      private func cropImage(image:UIImage, cropArea:CGRect){
          guard let cgImage = image.cgImage?.cropping(to: cropArea) else{return}
          saveImage(image: UIImage(cgImage: cgImage))
      }
      
      private func saveImage(image:UIImage){
          UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      }
      
    
}



//MARK: Gluing
extension ImageCropper{
//
//    //Calculate the total width of the new image
//    func getTotalWidth(images:[PHAsset]) -> CGFloat{
//        var total:CGFloat = 0
//        for image in images{
//            total += CGFloat(image.pixelWidth)
//        }
//        return total
//    }
//
//    //Calculate the total height of the new image
//    func getTotalHeight(images:[PHAsset]) -> CGFloat{
//        var total:CGFloat = 0
//        for image in images{
//            total += CGFloat(image.pixelHeight)
//        }
//        return total
//    }
//
    
    func stitchImage(images:[PHAsset]){
        
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
                
                let currentImage = images[index]
                let currentImageHeight = CGFloat(currentImage.pixelHeight)
                let currentImageWidth = CGFloat(currentImage.pixelWidth)
                let currentImageRect = CGRect(x: currentXPos, y: currentYPos, width: currentImageWidth, height: currentImageHeight)

                //Updates max height of row if needed.
                maxHeight = maxHeight < currentImageHeight ? currentImageHeight : maxHeight
                
                //Draw PHAsset on canvas.
                drawPHAsset(asset: currentImage, inRect: currentImageRect)
                
            
                currentXPos += currentImageWidth
            }
            currentYPos += maxHeight
        }
        
        
        let outputImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        saveImage(image: outputImage)
    }
    
    
    fileprivate func drawPHAsset(asset currentImage:PHAsset, inRect currentImageRect:CGRect){
        
        //Using sempahore to ensure that assets are drawn one by one.
        let semaphore = DispatchSemaphore(value: 0)
        var uiImage:UIImage?
        
        PHImageManager.default().requestImage(for: currentImage, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
            uiImage = image
            semaphore.signal()
        }
        
        semaphore.wait()
        if uiImage == nil{return}
        uiImage!.draw(in: currentImageRect, blendMode: .normal, alpha: 1)
        
    }
    
}



