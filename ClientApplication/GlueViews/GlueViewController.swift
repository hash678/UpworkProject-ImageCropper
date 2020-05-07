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
import JGProgressHUD

class GlueViewController: UIViewController {
    
    fileprivate lazy var progressHUD:JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please wait.."
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        return hud
    }()
    
    fileprivate var selectedCell:SquareImageCell?
    fileprivate let cellID = "MySquareCell"
    fileprivate let dragAnimationDuration:Double = 0.2
    
    
    var splitCount = 4
    fileprivate var imagesDatasource = [PHAsset]()
    fileprivate var originalLocations = [UIView:CGPoint]()
    fileprivate var myCells = [UIView]()
    @IBOutlet weak var mainCollectionView:UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        
        PermissionHelper.requestPermission {[weak self] (granted) in
            if granted{
                self?.openImagePicker()
            }else{
                self?.present(PermissionHelper.showAlert(nil), animated: true, completion: nil)
            }
        }
     
        
    }
    
    fileprivate func setupViews(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        mainCollectionView.collectionViewLayout = flowLayout
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(glueImages))
    }
    
    
    fileprivate func showError(){
        let alertController = UIAlertController (title: "An error occurred", message: "An unknown error occurred while putting the images together. ", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func openImagePicker(){
        
        
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = splitCount
        imagePicker.settings.selection.min = splitCount
        
        presentImagePicker(imagePicker, animated: true, select: nil, deselect: nil, cancel: {(assets) in
            //self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            
        }, finish: { (assets) in
            
            self.imagesDatasource = assets.sorted(by: { (a, b) -> Bool in
                
                
                return (a.creationDate ?? Date()).timeIntervalSince1970 < (b.creationDate  ?? Date()).timeIntervalSince1970
            })
            
            
            self.mainCollectionView.reloadData()
            
        }, completion: nil)
    
    }
    
    @objc fileprivate func glueImages(){
        progressHUD.show(in: self.view)
        updateSelectedCell(nil)
        ImageCropper.shared.stitchImage(images: imagesDatasource, progress: {[weak self]  (progress) in
            
            self?.progressHUD.progress = Float(progress)
            
        }, completion: {[weak self] (image) in
            self?.progressHUD.dismiss(animated: true)
            
            if let image = image{
                self?.shareImage(image: image)
            }else{
                self?.showError()
            }
        })
        
    }
    
    fileprivate func shareImage(image:UIImage){
        
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView=self.view
        present(activityViewController, animated: true, completion: nil)
        
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
        cell.selected(false)
        if !myCells.contains(cell){
            myCells.append(cell)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount = CGFloat(sqrt(Double(splitCount)))
        let width = (collectionView.frame.width / columnCount)
        let image = imagesDatasource[indexPath.row]
        
        let height = min(getScaledHeight(scaledWidth: width, actualWidth: CGFloat(image.pixelWidth), actualHeight: CGFloat(image.pixelHeight)),(collectionView.frame.height / columnCount))
        
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SquareImageCell
        
        updateSelectedCell(cell)
        
    }
    
    
    
    fileprivate func getScaledHeight(scaledWidth:CGFloat,actualWidth:CGFloat, actualHeight:CGFloat) -> CGFloat{
        let factor = actualWidth / scaledWidth
        return actualHeight / factor
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
        
        //Preserve initial location of view before dragging and update cell view to show border(if enabled)
        if sender.state == .began && originalLocations[currentView] == nil{
            originalLocations[currentView]  =  currentView.center
            let cell = currentView as! SquareImageCell
            updateSelectedCell(cell)
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
        
        //Update the indexs stored in each cell
        let temp = cellA.cellID
        cellA.cellID = cellB.cellID
        cellB.cellID = temp
        
        //Update cell border to show new highlighted image
        updateSelectedCell(cellA)
        
    }
    
    fileprivate func updateSelectedCell(_ newSelected:SquareImageCell?){
        selectedCell?.selected(false)
        newSelected?.selected(true)
        selectedCell = newSelected
        if newSelected != nil{
            mainCollectionView.bringSubviewToFront(newSelected!)
            
        }
        
    }
    
    
    fileprivate func swapPlaces(indexA:Int,indexB:Int, array:inout [PHAsset]){
        let temp = array[indexA]
        array[indexA] = array[indexB]
        array[indexB] = temp
    }
    
    
    
    
    
    
}



