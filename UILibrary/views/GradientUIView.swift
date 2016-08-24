//
//  GradientUIView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@IBDesignable
class GradientUIView: UIView {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        theLayer.colors = [colorTop.CGColor, colorBottom.CGColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}
