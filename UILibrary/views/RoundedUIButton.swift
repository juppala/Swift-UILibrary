//
//  RoundedUIButton.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedUIButton: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    private func layoutRoundRectLayer() {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = cornerRadius
    }
}