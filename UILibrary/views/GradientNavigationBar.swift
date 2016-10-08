//
//  GradientNavigationBar.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientNavigationBar: UINavigationBar {
    
    @IBInspectable
    var colorTop:UIColor = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            //setupView()
        }
    }
    
    @IBInspectable
    var colorBottom:UIColor = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            setupView()
        }
    }
    
    fileprivate func setupView() {
        let theLayer = CAGradientLayer()
        theLayer.frame = self.bounds
        theLayer.frame.size.height = 66.0
        
        theLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        
        theLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        theLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        UIGraphicsBeginImageContext(theLayer.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            theLayer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Set the UIImage as background property
            setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }
}

