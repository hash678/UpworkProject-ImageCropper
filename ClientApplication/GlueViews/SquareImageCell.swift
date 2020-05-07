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
    
    var enableBorders = true
    var selectedColor:CGColor =  UIColor.blue.cgColor
    var unSelectedColor:CGColor = UIColor.white.cgColor
    var selectedBorderWidth:CGFloat = 2
    var unSelectedBorderWidth:CGFloat = 1


    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(asset:PHAsset){
        PHImageManager.default().requestImage(for: asset, targetSize: .init(width: self.frame.width, height: self.frame.height), contentMode: .aspectFill, options: .none) { (image, info) in
            self.imageView.image = image
            }
        
    }
    
        func selected(_ selected:Bool){
            if !enableBorders{return}
        
            self.imageView.layer.borderWidth = selected ? selectedBorderWidth : unSelectedBorderWidth
            self.imageView.layer.borderColor = selected ? selectedColor : unSelectedColor
            self.imageView.layer.masksToBounds = true

       }
  
}

