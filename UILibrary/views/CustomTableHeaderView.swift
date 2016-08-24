//
//  CustomTableHeaderView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

class CustomTableHeaderView: AccordionTableViewHeaderView {
    static let height: CGFloat = 40
    static let reuseIdentifier = "TableHeaderViewIdentifier"
    @IBOutlet weak var accordionIcon: UIImageView!
    @IBOutlet weak var tableHeaderLabel: UILabel!
    
    func animateAccordion(open open: Bool) {
        UIView.animateWithDuration(0.25, animations: {
            self.accordionIcon.transform = CGAffineTransformMakeRotation(open ? (90.0 * CGFloat(M_PI)) / 180.0 : 0)
        })
    }
}

