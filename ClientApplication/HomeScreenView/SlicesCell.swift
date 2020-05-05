//
//  SlicesCell.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 05/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit

class SlicesCell:UICollectionViewCell{
    
    @IBOutlet weak var imageView:UIImageView!
    
    override var isSelected: Bool{
        didSet{
            self.selected(isSelected)
        }
    }
    fileprivate func selected(_ selected:Bool){
        self.imageView.backgroundColor = selected ? UIColor.black.withAlphaComponent(0.6) : UIColor.white
    }
}
