//
//  CustomTableHeaderView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

open class CustomTableHeaderView: AccordionTableViewHeaderView {
    open static let height: CGFloat = 40
    open static let reuseIdentifier = "TableHeaderViewIdentifier"
    @IBOutlet weak var accordionIcon: UIImageView!
    @IBOutlet open weak var tableHeaderLabel: UILabel!
    @IBOutlet open weak var actionsButton: UIButton!
    
    open func animateAccordion(open: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.accordionIcon.transform = CGAffineTransform(rotationAngle: open ? (90.0 * CGFloat(M_PI)) / 180.0 : 0)
        })
    }
}

