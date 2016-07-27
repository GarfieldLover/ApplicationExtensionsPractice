//
//  UIImage+RotatedImage.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 18/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public func rotatedImage(_ angle: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let rotatedViewBoxTransform = CGAffineTransform(rotationAngle: angle)
        rotatedViewBox.transform = rotatedViewBoxTransform
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsPushContext(UIGraphicsGetCurrentContext()!)
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translate(x: rotatedSize.width / 2, y: rotatedSize.height / 2);
        context?.rotate(byAngle: angle)
        self.draw(in: CGRect(
            x: -self.size.width / 2,
            y: -self.size.height / 2,
            width: self.size.width,
            height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIGraphicsPopContext()
        
        return rotatedImage!
    }
    
}
