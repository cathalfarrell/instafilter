//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Cathal Farrell on 26/05/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit

class ImageSaver: NSObject {

    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        // Once save completes - check for error
        guard let error = error else {
            successHandler?()
            return
        }

        errorHandler?(error)
    }
}
