//
//  InstructionsViewController.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 06/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import SwiftGifOrigin

class InstructionsViewController:UIViewController{
    
    var splitCount = 4
    @IBOutlet weak var slicesLabel: UILabel!
    @IBOutlet weak var gifView: UIImageView!
    
    @IBAction func openGlueController(_ sender: Any) {
        let glueViewController = self.storyboard?.instantiateViewController(withIdentifier: "glueViewController") as! GlueViewController
                   glueViewController.splitCount = self.splitCount
        
        self.navigationController?.popViewController(animated: true)
                   self.navigationController?.pushViewController(glueViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifView.loadGif(asset: "sampleGif.gif")
        slicesLabel.text = "\(splitCount) \(slicesLabel.text ?? "slices saved to camera roll")"
    }
    
}
