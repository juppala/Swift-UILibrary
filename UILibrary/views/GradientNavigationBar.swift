//
//  GradientNavigationBar.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@IBDesignable
class GradientNavigationBar: UINavigationBar {
    
    @IBInspectable
    var colorTop:UIColor = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            setupView()
        }
    }
    
    @IBInspectable
    var colorBottom:UIColor = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            setupView()
        }
    }
    
    private func setupView() {
        let theLayer = CAGradientLayer()
        theLayer.frame = self.bounds
        theLayer.frame.size.height = 66.0
        
        theLayer.colors = [colorTop.CGColor, colorBottom.CGColor]
        
        theLayer.startPoint = CGPointMake(0.5, 0.0)
        theLayer.endPoint = CGPointMake(0.5, 1.0)
        
        UIGraphicsBeginImageContext(theLayer.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            theLayer.renderInContext(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Set the UIImage as background property
            setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        }
    }
}

