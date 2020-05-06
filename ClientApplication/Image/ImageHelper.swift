//
//  AsyncImageHelpe.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 06/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit


//MARK: Operation Class
    /**
 The below code snippet is borrowed from stack overflow to address the problem of a race condition which was created while saving images.
 
 The snippet makes use of an operation block with AsynchronousOperations.
 
 Reference:
 https://stackoverflow.com/questions/45094706/waiting-for-completion-handler-to-complete-before-continuing
 Credits:
 Rob
 */
class ImageSaveOperation: AsynchronousOperation {

    let image: UIImage
    let imageCompletionBlock: ((NSError?) -> Void)?

    init(image: UIImage, imageCompletionBlock: ((NSError?) -> Void)? = nil) {
        self.image = image
        self.imageCompletionBlock = imageCompletionBlock

        super.init()
    }

    override func main() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        imageCompletionBlock?(error)
        complete()
    }

}
public class AsynchronousOperation : Operation {

    private let syncQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".opsync")

    override public var isAsynchronous: Bool { return true }

    private var _executing: Bool = false
    override private(set) public var isExecuting: Bool {
        get {
            return syncQueue.sync { _executing }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            syncQueue.sync { _executing = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    override private(set) public var isFinished: Bool {
        get {
            return syncQueue.sync { _finished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            syncQueue.sync { _finished = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }

    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting

    public func complete() {
        if isExecuting { isExecuting = false }

        if !isFinished { isFinished = true }
    }

    override public func start() {
        if isCancelled {
            isFinished = true
            return
        }

        isExecuting = true

        main()
    }
}

//MARK: Operation Class
   /**
The below code snippet is borrowed from stack overflow to address the problem of orientations applied to images by user or by applications like whatsapp and snapchat.

The snippet rotates the actual UIImage in accordance with its rotational data. This is done to preserve the rotation when the image is converted into CGImage for saving purposes.

Reference:
https://gist.github.com/schickling/b5d86cb070130f80bb40
Credits:
 @schickling
 https://gist.github.com/schickling
*/
extension UIImage{
        func fixOrientation() -> UIImage {

            guard let cgImage = cgImage else { return self }

            if imageOrientation == .up { return self }

            var transform = CGAffineTransform.identity

            //let size = CGSize(width: cgImage.width, height: cgImage.height)
            switch imageOrientation {

            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: CGFloat(Double.pi))

            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi/2))

            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: CGFloat(-Double.pi/2))

            case .up, .upMirrored:
                break
            @unknown default:
                break
            }

            switch imageOrientation {

            case .upMirrored, .downMirrored:
                transform.translatedBy(x: size.width, y: 0)
                //transform.scaledBy(x: -1, y: 1)

            case .leftMirrored, .rightMirrored:
                transform.translatedBy(x: size.height, y: 0)
                //transform.scaledBy(x: -1, y: 1)

            case .up, .down, .left, .right:
                break
            @unknown default:
                break
            }

            if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

                ctx.concatenate(transform)

                switch imageOrientation {

                case .left, .leftMirrored, .right, .rightMirrored:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

                default:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }

                if let finalImage = ctx.makeImage() {
                    return (UIImage(cgImage: finalImage))
                }
            }

            // something failed -- return original
            return self
        }
    
}


