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

