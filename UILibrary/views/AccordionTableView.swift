//
//  AccordionTableView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@objc protocol AccordionTableViewDelegate: UITableViewDelegate {
    optional func tableView(tableView: AccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    optional func tableView(tableView: AccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    optional func tableView(tableView: AccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    optional func tableView(tableView: AccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView)
}

protocol AccordionTableViewHeaderViewDelegate {
    func headerView(sectionHeaderView: AccordionTableViewHeaderView, didSelectHeaderInSection section: Int)
}

class AccordionTableViewHeaderView: UITableViewHeaderFooterView {
    /*!
     @desc  The section which this header view is part of.
     */
    var section: Int = 0
    
    var delegate: AccordionTableViewHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccordionTableViewHeaderView.touchedHeaderView(_:))))
    }
    
    func touchedHeaderView(recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.headerView(self, didSelectHeaderInSection: self.section)
        }
    }
}

class AccordionTableView: UITableView, UITableViewDataSource, UITableViewDelegate, AccordionTableViewDelegate, AccordionTableViewHeaderViewDelegate {
    
    var subclassDelegate: AccordionTableViewDelegate!
    
    var subclassDataSource: UITableViewDataSource!
    
    var openedSections: NSMutableSet = NSMutableSet()
    var numOfRowsForSection: NSMutableDictionary = NSMutableDictionary()
    
    /*!
     @desc  If set to NO, a max of one section will be open at a time.
     
     If set to YES, any amount of sections can be open at a time.
     
     Use 'sectionsInitiallyOpen' to specify which section should be
     open at the start, otherwise, all sections will be closed at
     the start even if the property is set to YES.
     
     The default value is NO.
     */
    var allowMultipleSectionsOpen: Bool = false
    /*!
     @desc  If set to YES, one section will always be open.
     
     If set to NO, all sections can be closed.
     
     Note that this does NOT influence 'sectionsAlwaysOpen.' Also,
     use 'sectionsInitiallyOpen' to specify which section should be
     open at the start, otherwise, all sections will be closed at
     the start even if the property is set to YES.
     
     The default value is NO.
     */
    var keepOneSectionOpen: Bool = false
    /*!
     @desc  Defines which sections should be open the first time the
     table is shown.
     */
    var initialOpenSections = [Int]()
    /*!
     @desc  Defines which sections will always be open.
     The headers of these sections will not call the
     AccordionTableViewDelegate methods.
     */
    var sectionsAlwaysOpen = [Int]()
    /*!
     @desc  Enables the fading of cells for the last two rows of the
     table. The fix can remove some of the animation clunkyness
     that happens at the last table view cells.
     
     The default value is NO.
     */
    var enableAnimationFix: Bool = false
    
    func initializeVars() {
        self.openedSections = NSMutableSet()
        self.numOfRowsForSection = NSMutableDictionary()
        self.allowMultipleSectionsOpen = false
        self.enableAnimationFix = false
        self.keepOneSectionOpen = false
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.initializeVars()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initializeVars()
    }
    
    func isSectionOpen(section: Int) -> Bool {
        return self.openedSections.containsObject(section)
    }
    
    func isAlwaysOpenedSection(section: Int) -> Bool {
        return self.sectionsAlwaysOpen.contains(section)
    }
    
    func addOpenedSection(section: Int) {
        self.openedSections.addObject(section)
    }
    
    func removeOpenedSection(section: Int) {
        self.openedSections.removeObject(section)
    }
    
    func getIndexPathsForSection(section: Int) -> [AnyObject] {
        let numOfRows: Int = Int((self.numOfRowsForSection[section]?.intValue)!)
        var indexPaths: [AnyObject] = NSMutableArray() as [AnyObject]
        for row in 0 ..< numOfRows {
            indexPaths.append(NSIndexPath(forRow: row, inSection: section))
        }
        return indexPaths
    }
    
    func toggleSection(section: Int) {
        let headerView: AccordionTableViewHeaderView = (self.headerViewForSection(section) as! AccordionTableViewHeaderView)
        self.headerView(headerView, didSelectHeaderInSection: section)
    }
    
    override var delegate: UITableViewDelegate? {
        didSet {
            let castedDelegate = unsafeBitCast(delegate, AccordionTableViewDelegate.self)
            self.subclassDelegate = castedDelegate
            super.delegate = self
        }
    }
    
    override var dataSource: UITableViewDataSource? {
        didSet {
            self.subclassDataSource = dataSource
            super.dataSource = self
        }
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject {
        if self.subclassDataSource!.respondsToSelector(aSelector) {
            return self.subclassDataSource!
        }
        else if self.subclassDelegate!.respondsToSelector(aSelector) {
            return self.subclassDelegate!
        }
        return super.forwardingTargetForSelector(aSelector)!
    }
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        if super.respondsToSelector(aSelector) {
            return true
        } else if self.subclassDelegate != nil {
            return self.subclassDelegate.respondsToSelector(aSelector)
        } else if self.subclassDataSource != nil {
            return self.subclassDataSource.respondsToSelector(aSelector)
        }
        return false
    }
    
    private func setSectionsAlwaysOpen(alwaysOpenedSections: [Int]) {
        self.sectionsAlwaysOpen = alwaysOpenedSections
        if sectionsAlwaysOpen.count > 0 {
            for alwaysOpenedSection: Int in sectionsAlwaysOpen {
                self.addOpenedSection(alwaysOpenedSection)
            }
        }
    }
    
    private func setInitialOpenSections(initialOpenedSections: [Int]) {
        self.initialOpenSections = initialOpenedSections
        if initialOpenSections.count > 0 {
            for section: Int in initialOpenSections {
                self.addOpenedSection(section)
            }
        }
    }
    
    func headerView(sectionHeaderView: AccordionTableViewHeaderView, didSelectHeaderInSection section: Int) {
        // Do not interact with sections that are always opened
        if self.isAlwaysOpenedSection(section) {
            return
        }
        // Keep at least one section open
        if self.keepOneSectionOpen {
            var countOfOpenSections: Int = self.openedSections.count
            if self.sectionsAlwaysOpen.count > 0 {
                // Subtract 'sectionsAlwaysOpen' from 'openedSections'
                var openedSectionsCopy: [Int] = self.openedSections.mutableCopy() as! [Int]
                openedSectionsCopy = openedSectionsCopy.filter { sectionsAlwaysOpen.indexOf($0) != nil }
                countOfOpenSections = openedSectionsCopy.count
            }
            if countOfOpenSections == 1 && self.isSectionOpen(section) {
                return
            }
        }
        let openSection: Bool = self.isSectionOpen(section)
        // Create an array of index paths that will be inserted/removed
        let indexPathsToModify: [AnyObject] = self.getIndexPathsForSection(section)
        self.beginUpdates()
        // Insert/remove rows to simulate opening/closing of a header
        if !openSection {
            self.openSection(section, withHeaderView: sectionHeaderView, andIndexPaths: indexPathsToModify)
        }
        else {
            // The section is currently open
            self.closeSection(section, withHeaderView: sectionHeaderView, andIndexPaths: indexPathsToModify)
        }
        // Auto-collapse the rest of the opened sections
        if !self.allowMultipleSectionsOpen && !openSection {
            self.autoCollapseAllSectionsExceptSection(section)
        }
        self.endUpdates()
    }
    
    func openSection(section: Int, withHeaderView sectionHeaderView: AccordionTableViewHeaderView, andIndexPaths indexPathsToModify: [AnyObject]) {
        if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:willOpenSection:withHeader:))) {
            self.subclassDelegate.tableView!(self, willOpenSection: section, withHeader: sectionHeaderView)
        }
        var insertAnimation: UITableViewRowAnimation = .Top
        if !self.allowMultipleSectionsOpen {
            for openSection in self.openedSections {
                if openSection.integerValue < section {
                    insertAnimation = .Bottom
                }
            }
        }
        if self.enableAnimationFix {
            if self.openedSections.count > 0 && (section == self.numOfRowsForSection.count - 1 || section == self.numOfRowsForSection.count - 2) && !self.allowsMultipleSelection {
                insertAnimation = .Fade
            }
        }
        self.addOpenedSection(section)
        self.beginUpdates()
        CATransaction.setCompletionBlock({
            if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:didOpenSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, didOpenSection: section, withHeader: sectionHeaderView)
            }
        })
        
        
        self.insertRowsAtIndexPaths(indexPathsToModify as! [NSIndexPath], withRowAnimation: insertAnimation)
        self.endUpdates()
    }
    
    func closeSection(section: Int, withHeaderView sectionHeaderView: AccordionTableViewHeaderView, andIndexPaths indexPathsToModify: [AnyObject]) {
        if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:willCloseSection:withHeader:))) {
            self.subclassDelegate.tableView!(self, willCloseSection: section, withHeader: sectionHeaderView)
        }
        self.removeOpenedSection(section)
        self.beginUpdates()
        CATransaction.setCompletionBlock({
            if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:didCloseSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, didCloseSection: section, withHeader: sectionHeaderView)
            }
        })
        self.deleteRowsAtIndexPaths(indexPathsToModify as! [NSIndexPath], withRowAnimation: .Top)
        self.endUpdates()
    }
    
    func autoCollapseAllSectionsExceptSection(section: Int) {
        // Get all of the sections that we need to close
        let sectionsToClose: NSMutableSet = NSMutableSet()
        for openedSection in self.openedSections {
            if openedSection.integerValue != section && !self.isAlwaysOpenedSection(openedSection.integerValue) {
                sectionsToClose.addObject(openedSection)
            }
        }
        // Close the found sections
        for sectionToClose in sectionsToClose {
            if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:willCloseSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, willCloseSection: sectionToClose.integerValue, withHeader: self.headerViewForSection(sectionToClose.integerValue)!)
            }
            // Change animations based off which sections are closed
            var closeAnimation: UITableViewRowAnimation = .Top
            if section < sectionToClose.integerValue {
                closeAnimation = .Bottom
            }
            if self.enableAnimationFix {
                if (sectionToClose.integerValue == self.numOfRowsForSection.count - 1 || sectionToClose.integerValue == self.numOfRowsForSection.count - 2) && !self.allowsMultipleSelection {
                    closeAnimation = .Fade
                }
            }
            // Delete the cells for section that is closing
            let indexPathsToDelete: [AnyObject] = self.getIndexPathsForSection(sectionToClose.integerValue)
            self.removeOpenedSection(sectionToClose.integerValue)
            self.beginUpdates()
            CATransaction.setCompletionBlock({
                if self.subclassDelegate.respondsToSelector(#selector(AccordionTableViewDelegate.tableView(_:didCloseSection:withHeader:))) {
                    self.subclassDelegate.tableView!(self, didCloseSection: sectionToClose.integerValue, withHeader: self.headerViewForSection(sectionToClose.integerValue)!)
                }
            })
            self.deleteRowsAtIndexPaths(indexPathsToDelete as! [NSIndexPath], withRowAnimation: closeAnimation)
            self.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows: Int = 0
        if self.subclassDataSource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
            numOfRows = self.subclassDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
        self.numOfRowsForSection[section] = numOfRows
        return (self.isSectionOpen(section)) ? numOfRows : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // We implement this purely to satisfy the Xcode UITableViewDataSource warning
        return self.subclassDataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //if self.subclassDelegate.respondsToSelector(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))) {
        if let headerView = self.subclassDelegate.tableView!(tableView, viewForHeaderInSection: section) as? AccordionTableViewHeaderView {
            headerView.section = section
            headerView.delegate = self
            return headerView
        }
        return UIView()
    }
}
