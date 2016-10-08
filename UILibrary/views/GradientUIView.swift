//
//  GradientUIView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientUIView: UIView {
    
    @IBInspectable
    var colorTop:UIColor = UIColor(red: 0.0/255.0, green: 68.0/255.0, blue: 234.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            setupView()
        }
    }
    
    @IBInspectable
    var colorBottom:UIColor = UIColor(red: 39.0/255.0, green: 169.0/255.0, blue: 248.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        theLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }
    
    override open class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
}
