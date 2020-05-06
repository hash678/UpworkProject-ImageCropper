//
//  PermissionHelper.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 06/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PermissionHelper{

    
     static func checkPermissions() -> Bool{
        let status = PHPhotoLibrary.authorizationStatus()
      
        if  status == .authorized{
            return true
        }
        return false
    }
    
    
    static func showAlert(_ cancelCompletion:(() -> Void)?) -> UIAlertController{
        let alertController = UIAlertController (title: "No permission", message: "It seems like you have not given permission to access photos. Please go to the settings to do so.", preferredStyle: .alert)

           let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                   return
               }

               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                   })
               }
           }
         
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert) in
            cancelCompletion?()
        }
         
           alertController.addAction(cancelAction)
          alertController.addAction(settingsAction)
            return alertController
    }
    
    
}
