//
//  Extension.swift
//  HeadShot
//
//  Created by Maat on 04/07/2018.
//  Copyright © 2018 Maat. All rights reserved.
//
import SpriteKit
import GameplayKit

extension UIImage {
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a image cropped within a circle
    var circle: UIImage? {
        let length = min(size.width, size.height)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: length, height: length)))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = length/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    
    
    
    
    
}

