//
//  ViewController.swift
//  PracticeDragDrop
//
//  Created by Hassan Abbasi on 04/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

class GlueViewController: UIViewController {
    
    
    
    
    fileprivate let cellID = "MySquareCell"
    fileprivate let dragAnimationDuration:Double = 0.5
    
    
    var splitCount = 4
    fileprivate var imagesDatasource = [PHAsset]()
    fileprivate var originalLocations = [UIView:CGPoint]()
    fileprivate var myCells = [UIView]()
    @IBOutlet weak var mainCollectionView:UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        openImagePicker()
    }
    
    fileprivate func setupViews(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        mainCollectionView.collectionViewLayout = flowLayout
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(glueImages))
    }
    
    fileprivate func openImagePicker(){
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = splitCount
        imagePicker.settings.selection.min = splitCount
        
        presentImagePicker(imagePicker, animated: true, select: nil, deselect: nil, cancel: nil, finish: { (assets) in
            
            self.imagesDatasource = assets.sorted(by: { (a, b) -> Bool in
                a.creationDate ?? Date() < b.creationDate  ?? Date()
            })
            
            
            self.mainCollectionView.reloadData()
            
        }, completion: nil)
        
        
    }
    
    @objc fileprivate func glueImages(){
        
        ImageCropper.shared.stitchImage(images: imagesDatasource)
        
    }
    
    
    
    
    
}


extension GlueViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesDatasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SquareImageCell
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panView))
        cell.cellID = indexPath.row
        cell.addGestureRecognizer(gesture)
        cell.setImage(asset: imagesDatasource[indexPath.row])
        if !myCells.contains(cell){
            myCells.append(cell)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount = CGFloat(sqrt(Double(splitCount)))
        let width = (collectionView.frame.width / columnCount)
        return CGSize(width: width, height: width)
    }
    
}
extension GlueViewController{
   
    
    /// Find view currently being hovered over
    /// - Parameters:
    ///   - location: Location of hovering
    ///   - currentView: View being dragged
    /// - Returns: View that is being hovered over if any.
    fileprivate func overlappingView(location:CGPoint, currentView:UIView) -> UIView?{
        for cell in myCells{
            if cell.frame.contains(location) && cell != currentView{
                return cell
            }
        }
        return nil
    }
    
    
    
    
    
    @objc func panView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        guard let currentView = sender.view  else{return}
        
        //Preserve initial location of view before dragging.
        if sender.state == .began && originalLocations[currentView] == nil{
            originalLocations[currentView]  =  currentView.center
        }
        
        
        mainCollectionView.bringSubviewToFront(currentView)
        currentView.center = CGPoint(x: currentView.center.x + translation.x,
                                    y: currentView.center.y + translation.y)
        sender.setTranslation(CGPoint(x: 0, y: 0), in: currentView)
        
        
        
        
        //Switch views and update the image array.
        if sender.state == .ended{
            let currentViewLocation = CGPoint(x: currentView.center.x,
                                      y: currentView.center.y)
            
            guard let moveTo = self.overlappingView(location: currentViewLocation, currentView: currentView) else{
               
                UIView.animate(withDuration: dragAnimationDuration) {
                    currentView.center = self.originalLocations[sender.view!]!
                }
                
                return
            }
            
            
            
            swapImages(firstView: currentView, secondView: moveTo)
           
            UIView.animate(withDuration: dragAnimationDuration) {
                
                
                let currentCenter = self.originalLocations[currentView]!
                currentView.center = moveTo.center
                moveTo.center = currentCenter
                
                self.originalLocations[currentView] = currentView.center
                self.originalLocations[moveTo] = moveTo.center
           
            }
            
        }
        
        
        
    }
    
    
    /// Swap images in array
    /// - Parameters:
    ///   - firstView: The first collectionview cell user swapped
    ///   - secondView: The second collectionview cell user swapper
    fileprivate func swapImages(firstView:UIView, secondView:UIView){
          let cellA = firstView as! SquareImageCell
                     let cellB = secondView as! SquareImageCell
                     swapPlaces(indexA: cellA.cellID, indexB: cellB.cellID, array: &self.imagesDatasource)
                     
      }
    
    
       fileprivate func swapPlaces(indexA:Int,indexB:Int, array:inout [PHAsset]){
           let temp = array[indexA]
           array[indexA] = array[indexB]
           array[indexB] = temp
       }
       
    
  
    
}


