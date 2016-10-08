//
//  AccordionTableView.swift
//  UILibrary
//
//  Created by Jagadish Uppala on 4/10/16.
//  Copyright © 2016 Jagadish Uppala. All rights reserved.
//

import UIKit

@objc public protocol AccordionTableViewDelegate: UITableViewDelegate {
    @objc optional func tableView(_ tableView: AccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    @objc optional func tableView(_ tableView: AccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    @objc optional func tableView(_ tableView: AccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView)
    
    @objc optional func tableView(_ tableView: AccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView)
}

public protocol AccordionTableViewHeaderViewDelegate {
    func headerView(_ sectionHeaderView: AccordionTableViewHeaderView, didSelectHeaderInSection section: Int)
}

open class AccordionTableViewHeaderView: UITableViewHeaderFooterView {
    /*!
     @desc  The section which this header view is part of.
     */
    var section: Int = 0
    
    var delegate: AccordionTableViewHeaderViewDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccordionTableViewHeaderView.touchedHeaderView(_:))))
    }
    
    func touchedHeaderView(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.headerView(self, didSelectHeaderInSection: self.section)
        }
    }
}

open class AccordionTableView: UITableView, UITableViewDataSource, AccordionTableViewDelegate, AccordionTableViewHeaderViewDelegate {
    
    var subclassDelegate: AccordionTableViewDelegate!
    
    var subclassDataSource: UITableViewDataSource!
    
    open var openedSections: NSMutableSet = NSMutableSet()
    
    var numOfRowsForSection: NSMutableDictionary = NSMutableDictionary()
    
    /*!
     @desc  If set to NO, a max of one section will be open at a time.
     
     If set to YES, any amount of sections can be open at a time.
     
     Use 'sectionsInitiallyOpen' to specify which section should be
     open at the start, otherwise, all sections will be closed at
     the start even if the property is set to YES.
     
     The default value is NO.
     */
    open var allowMultipleSectionsOpen: Bool = false
    
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
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initializeVars()
    }
    
    func isSectionOpen(_ section: Int) -> Bool {
        return self.openedSections.contains(section)
    }
    
    func isAlwaysOpenedSection(_ section: Int) -> Bool {
        return self.sectionsAlwaysOpen.contains(section)
    }
    
    func addOpenedSection(_ section: Int) {
        self.openedSections.add(section)
    }
    
    func removeOpenedSection(_ section: Int) {
        self.openedSections.remove(section)
    }
    
    func getIndexPathsForSection(_ section: Int) -> [AnyObject] {
        let numOfRows: Int = self.numOfRowsForSection[section] as! Int
        var indexPaths: [AnyObject] = NSMutableArray() as [AnyObject]
        for row in 0 ..< numOfRows {
            indexPaths.append(IndexPath(row: row, section: section) as AnyObject)
        }
        return indexPaths
    }
    
    func toggleSection(_ section: Int) {
        let headerView: AccordionTableViewHeaderView = (self.headerView(forSection: section) as! AccordionTableViewHeaderView)
        self.headerView(headerView, didSelectHeaderInSection: section)
    }
    
    override open var delegate: UITableViewDelegate? {
        didSet {
            let castedDelegate = unsafeBitCast(delegate, to: AccordionTableViewDelegate.self)
            self.subclassDelegate = castedDelegate
            super.delegate = self
        }
    }
    
    override open var dataSource: UITableViewDataSource? {
        didSet {
            self.subclassDataSource = dataSource
            super.dataSource = self
        }
    }
    
    open func forwardingTarget(for aSelector: Selector) -> AnyObject {
        if self.subclassDataSource!.responds(to: aSelector) {
            return self.subclassDataSource!
        }
        else if self.subclassDelegate!.responds(to: aSelector) {
            return self.subclassDelegate!
        }
        return super.forwardingTarget(for: aSelector)! as AnyObject
    }
    
    override open func responds(to aSelector: Selector) -> Bool {
        if super.responds(to: aSelector) {
            return true
        } else if self.subclassDelegate != nil {
            return self.subclassDelegate.responds(to: aSelector)
        } else if self.subclassDataSource != nil {
            return self.subclassDataSource.responds(to: aSelector)
        }
        return false
    }
    
    fileprivate func setSectionsAlwaysOpen(_ alwaysOpenedSections: [Int]) {
        self.sectionsAlwaysOpen = alwaysOpenedSections
        if sectionsAlwaysOpen.count > 0 {
            for alwaysOpenedSection: Int in sectionsAlwaysOpen {
                self.addOpenedSection(alwaysOpenedSection)
            }
        }
    }
    
    fileprivate func setInitialOpenSections(_ initialOpenedSections: [Int]) {
        self.initialOpenSections = initialOpenedSections
        if initialOpenSections.count > 0 {
            for section: Int in initialOpenSections {
                self.addOpenedSection(section)
            }
        }
    }
    
    public func headerView(_ sectionHeaderView: AccordionTableViewHeaderView, didSelectHeaderInSection section: Int) {
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
                openedSectionsCopy = openedSectionsCopy.filter { sectionsAlwaysOpen.index(of: $0) != nil }
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
    
    func openSection(_ section: Int, withHeaderView sectionHeaderView: AccordionTableViewHeaderView, andIndexPaths indexPathsToModify: [AnyObject]) {
        if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:willOpenSection:withHeader:))) {
            self.subclassDelegate.tableView!(self, willOpenSection: section, withHeader: sectionHeaderView)
        }
        var insertAnimation: UITableViewRowAnimation = .top
        if !self.allowMultipleSectionsOpen {
            for openSection in self.openedSections {
                if (openSection as AnyObject).intValue < section {
                    insertAnimation = .bottom
                }
            }
        }
        if self.enableAnimationFix {
            if self.openedSections.count > 0 && (section == self.numOfRowsForSection.count - 1 || section == self.numOfRowsForSection.count - 2) && !self.allowsMultipleSelection {
                insertAnimation = .fade
            }
        }
        self.addOpenedSection(section)
        self.beginUpdates()
        CATransaction.setCompletionBlock({
            if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:didOpenSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, didOpenSection: section, withHeader: sectionHeaderView)
            }
        })
        
        
        self.insertRows(at: indexPathsToModify as! [IndexPath], with: insertAnimation)
        self.endUpdates()
    }
    
    func closeSection(_ section: Int, withHeaderView sectionHeaderView: AccordionTableViewHeaderView, andIndexPaths indexPathsToModify: [AnyObject]) {
        if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:willCloseSection:withHeader:))) {
            self.subclassDelegate.tableView!(self, willCloseSection: section, withHeader: sectionHeaderView)
        }
        self.removeOpenedSection(section)
        self.beginUpdates()
        CATransaction.setCompletionBlock({
            if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:didCloseSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, didCloseSection: section, withHeader: sectionHeaderView)
            }
        })
        self.deleteRows(at: indexPathsToModify as! [IndexPath], with: .top)
        self.endUpdates()
    }
    
    func autoCollapseAllSectionsExceptSection(_ section: Int) {
        // Get all of the sections that we need to close
        let sectionsToClose: NSMutableSet = NSMutableSet()
        for openedSection in self.openedSections {
            if (openedSection as AnyObject).intValue != section && !self.isAlwaysOpenedSection((openedSection as AnyObject).intValue) {
                sectionsToClose.add(openedSection)
            }
        }
        // Close the found sections
        for sectionToClose in sectionsToClose {
            if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:willCloseSection:withHeader:))) {
                self.subclassDelegate.tableView!(self, willCloseSection: (sectionToClose as AnyObject).intValue, withHeader: self.headerView(forSection: (sectionToClose as AnyObject).intValue)!)
            }
            // Change animations based off which sections are closed
            var closeAnimation: UITableViewRowAnimation = .top
            if section < (sectionToClose as AnyObject).intValue {
                closeAnimation = .bottom
            }
            if self.enableAnimationFix {
                if ((sectionToClose as AnyObject).intValue == self.numOfRowsForSection.count - 1 || (sectionToClose as AnyObject).intValue == self.numOfRowsForSection.count - 2) && !self.allowsMultipleSelection {
                    closeAnimation = .fade
                }
            }
            // Delete the cells for section that is closing
            let indexPathsToDelete: [AnyObject] = self.getIndexPathsForSection((sectionToClose as AnyObject).intValue)
            self.removeOpenedSection((sectionToClose as AnyObject).intValue)
            self.beginUpdates()
            CATransaction.setCompletionBlock({
                if self.subclassDelegate.responds(to: #selector(AccordionTableViewDelegate.tableView(_:didCloseSection:withHeader:))) {
                    self.subclassDelegate.tableView!(self, didCloseSection: (sectionToClose as AnyObject).intValue, withHeader: self.headerView(forSection: (sectionToClose as AnyObject).intValue)!)
                }
            })
            self.deleteRows(at: indexPathsToDelete as! [IndexPath], with: closeAnimation)
            self.endUpdates()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows: Int = 0
        if self.subclassDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
            numOfRows = self.subclassDataSource.tableView(tableView, numberOfRowsInSection: section)
        }
        self.numOfRowsForSection[section] = numOfRows
        return (self.isSectionOpen(section)) ? numOfRows : 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We implement this purely to satisfy the Xcode UITableViewDataSource warning
        return self.subclassDataSource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //if self.subclassDelegate.respondsToSelector(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))) {
        if let headerView = self.subclassDelegate.tableView!(tableView, viewForHeaderInSection: section) as? AccordionTableViewHeaderView {
            headerView.section = section
            headerView.delegate = self
            return headerView
        }
        return UIView()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        print(self.subclassDataSource.numberOfSections!(in: tableView))
        return self.subclassDataSource.numberOfSections!(in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.subclassDelegate.tableView!(tableView, estimatedHeightForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.subclassDelegate.tableView!(tableView, heightForFooterInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.subclassDelegate.tableView!(tableView, heightForHeaderInSection: section)
    }

    /*
    public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //cell.accessoryView?.tintColor = UIColor(hexString: "#ffffffff")
        cell!.tintColor = UIColor(hexString: "#ffffffff")
    }
    
    public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let gesture = tableView.gestureRecognizers![1] as! UIPanGestureRecognizer
        let velocity = gesture.velocityInView(tableView)
        print("indexPath.section \(indexPath.section)")
        print("indexPath.section \(indexPath.row)")
        if velocity.x != 0.0 || velocity.y != 0.0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            //cell.accessoryView?.tintColor = UIColor(hexString: "#049fd9ff")
            cell!.tintColor = UIColor(hexString: "#049fd9ff")
        }
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //cell.accessoryView?.tintColor = UIColor(hexString: "#049fd9ff")
        cell!.tintColor = UIColor(hexString: "#049fd9ff")
    }
    
    
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //cell.accessoryView?.tintColor = UIColor(hexString: "#049fd9ff")
        cell!.tintColor = UIColor(hexString: "#049fd9ff")
        return indexPath
    }*/
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.characters.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
