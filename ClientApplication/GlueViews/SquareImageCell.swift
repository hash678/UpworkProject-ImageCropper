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
    
    var cellID:Int = 0
    

    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(asset:PHAsset){
        PHImageManager.default().requestImage(for: asset, targetSize: .init(width: self.frame.width, height: self.frame.height), contentMode: .aspectFill, options: .none) { (image, info) in
            self.imageView.image = image
            }
        
    }
  
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
