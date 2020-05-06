//
//  SquareImageCell.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 05/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import Photos
class SquareImageCell:UICollectionViewCell{
    
    var cellID:Int = -1
    

    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(asset:PHAsset){
        PHImageManager.default().requestImage(for: asset, targetSize: .init(width: self.frame.width, height: self.frame.height), contentMode: .aspectFill, options: .none) { (image, info) in
            self.imageView.image = image
            }
        
    }
    
        func selected(_ selected:Bool){
          
        
            self.imageView.layer.borderWidth = selected ? 2 : 1
            self.imageView.layer.borderColor = selected ? UIColor.blue.cgColor : UIColor.white.cgColor
        self.imageView.layer.masksToBounds = true

       }
  
}

