//
//  AsyncImageHelpe.swift
//  ClientApplication
//
//  Created by Hassan Abbasi on 06/05/2020.
//  Copyright © 2020 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit

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
