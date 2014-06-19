//
//  SettingViewController.swift
//  IDD Dialer
//
//  Created by Raymond Lee on 17/6/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

import UIKit
import Foundation

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectorTableViewControllerDelegate, UISearchBarDelegate, WYPopoverControllerDelegate {
    
    
    @IBOutlet var onAppCallSwitch:UISwitch
    var isEditing:Bool
    
    @IBOutlet var backBtn:UIButton
    @IBOutlet var searchBar:UISearchBar
    
    var addIDDVC:AddIDDViewController
    
    var sectionViewArray:UIView[]?
    var centerViewArray:UIView[]?
    var preferenceViewController:SelectorTableViewController
    
    var selectedCell:NSString?
    
    @IBOutlet var settingTableView:UITableView
    @IBOutlet var aboutView:UITextView
    
    var preferPopoverController:WYPopoverController
    
     init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        isEditing = false
        preferenceViewController = SelectorTableViewController()
        preferPopoverController = WYPopoverController(contentViewController: preferenceViewController)
        addIDDVC = AddIDDViewController(nibName: "AddIDDViewController", bundle: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.scrollsToTop = true
        
        // loop around subviews of UISearchBar
//        for subview : UIView! in searchBar.subviews {
//            for subview1 : UIView! in subview.subviews {
//                if let searchBarSubview = subview1 as? UITextField {
//                    
//                    // set style of keyboard
//                    searchBarSubview.keyboardAppearance = UIKeyboardAppearance.Dark
//                    
//                    // always force return key to be enabled
//                    searchBarSubview.enablesReturnKeyAutomatically = false
//                }
//            }
//        }
        
        preferenceViewController.delegate = self
        preferenceViewController.preferredContentSize = CGSizeMake(140, 0)
        
        var tempSectionViewArray = UIView[]()
        var tempCenterViewArray = UIView[]()
        
        for  x in 0 .. numberOfSectionsInTableView(settingTableView) {
            var sectionView = UIView(frame: CGRectMake(0, 0, settingTableView.frame.size.width, tableView(settingTableView, heightForHeaderInSection: x)))
            sectionView.backgroundColor = UIColor.clearColor()
            var centerView = UILabel(frame: CGRectMake(0, 0, 180, 20))
            
            centerView.backgroundColor = colorForHeader(section: x)
            centerView.textAlignment = NSTextAlignment.Center
            centerView.layer.cornerRadius = 10
            centerView.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            centerView.textColor = UIColor.whiteColor()
            centerView.text = tableView(settingTableView, titleForHeaderInSection: x)
            sectionView.addSubview(centerView)
            centerView.center = CGPointMake(sectionView.frame.size.width / 2, sectionView.frame.size.height / 2)
            tempSectionViewArray.append(sectionView)
            tempCenterViewArray.append(centerView)
        }
        sectionViewArray = tempSectionViewArray
        centerViewArray = tempCenterViewArray
        
        let buildNumber = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"] as String
        let appVersion = NSBundle.mainBundle().infoDictionary[kCFBundleVersionKey] as String
        aboutView.text = "\n\n\n IDD Dialer\nDeveloped by Raymond Lee\nVersion: " + appVersion + "\nBuild: "+buildNumber
        
        onAppCallSwitch.on = (NSUserDefaults.standardUserDefaults().objectForKey("isOnAppCall") as NSNumber).boolValue
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("addIddDone:"), name: "AddIDDDone", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        settingTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollViewDidScroll(settingTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func iddArray()->IDDRecord[] {
        let keyword = searchBar.text.lowercaseString
        if !keyword.isEmpty {
            var filteredArray = IDDRecord[]()
            for iddRecord in DiallingCodesHelper.sharedHelper.iddArray {
                let targetIdd = iddRecord.iddCode
                if targetIdd.bridgeToObjectiveC().containsString(keyword) {
                    filteredArray.append(iddRecord)
                }
            }
            return filteredArray;
        } else {
            return DiallingCodesHelper.sharedHelper.iddArray
        }
    }
    
    func countriesArray()->String[] {
        let keyword = searchBar.text.lowercaseString
        if !keyword.isEmpty {
            var filteredArray = String[]()
            for cc in DiallingCodesHelper.sharedHelper.countryCodeArray {
                var isMatched = false
                if cc.lowercaseString.bridgeToObjectiveC().containsString(keyword) {
                    isMatched = true
                }
                if !isMatched {
                    if let tempDiallingCode = DiallingCodesHelper.sharedHelper.diallingCodeByCode(cc) {
                        let dialingCode  = tempDiallingCode.lowercaseString
                        if !dialingCode.isEmpty {
                            if  dialingCode.bridgeToObjectiveC().containsString(keyword) {
                                isMatched = true;
                            }
                        }
                        if (!isMatched) {
                            if let tempName = DiallingCodesHelper.sharedHelper.countryNameByCode(cc) {
                                let name = tempName.lowercaseString
                                if name.bridgeToObjectiveC().containsString(keyword) {
                                    isMatched = true;
                                }
                            }
                        }
                    }
                }
                if isMatched {
                    filteredArray.append(cc)
                }
                
            }
            return filteredArray;
        } else {
            return DiallingCodesHelper.sharedHelper.countryCodeArray;
        }
    }
    
    func disableCountriesArray()->String[] {
        let keyword = searchBar.text.lowercaseString
        if !keyword.isEmpty {
            var filteredArray = String[]()
            for cc in DiallingCodesHelper.sharedHelper.disabledCountryCodeArray {
                var isMatched = false
                if cc.lowercaseString.bridgeToObjectiveC().containsString(keyword) {
                    isMatched = true
                }
                if !isMatched {
                    if let tempDiallingCode = DiallingCodesHelper.sharedHelper.diallingCodeByCode(cc) {
                        let dialingCode  = tempDiallingCode.lowercaseString
                        if !dialingCode.isEmpty {
                            if  dialingCode.bridgeToObjectiveC().containsString(keyword) {
                                isMatched = true;
                            }
                        }
                        if (!isMatched) {
                            if let tempName = DiallingCodesHelper.sharedHelper.countryNameByCode(cc) {
                                let name = tempName.lowercaseString
                                if name.bridgeToObjectiveC().containsString(keyword) {
                                    isMatched = true;
                                }
                            }
                        }
                    }
                }
                if isMatched {
                    filteredArray.append(cc)
                }
                
            }
            return filteredArray;
        } else {
            return DiallingCodesHelper.sharedHelper.disabledCountryCodeArray;
        }
    }
    
    @IBAction func switchValueChanged(sender:AnyObject){
        if sender as UISwitch == onAppCallSwitch {
            NSUserDefaults.standardUserDefaults().setBool(onAppCallSwitch.on, forKey: "isOnAppCall")
        }
    }
    
    @IBAction func addIDD(sender:AnyObject){
        presentViewController(addIDDVC, animated: true, completion: nil)
    }
    
    func addIddDone(notification:NSNotification){
        let inIddRecord = notification.userInfo["IDDRecord"] as IDDRecord
        
        if !inIddRecord.iddCode.isEmpty{
            for iddRecord in DiallingCodesHelper.sharedHelper.iddArray {
                if iddRecord.iddCode == inIddRecord.iddCode {
                    return
                }
            }
            DiallingCodesHelper.sharedHelper.iddArray.append(inIddRecord)
        }
        settingTableView.reloadData()
    }
    
    @IBAction func editTV(sender:AnyObject) {
        if let barButton = sender as? UIBarButtonItem{
            settingTableView.setEditing(!isEditing, animated: true)
            isEditing = !isEditing;
            backBtn.hidden = isEditing
            barButton.title  = isEditing ? "Done" : "Edit"
            barButton.tintColor  = isEditing ? UIColor.redColor() : nil
        }
    }
    
    @IBAction func back(sender:AnyObject) {
        updatePlits()
        NSNotificationCenter.defaultCenter().postNotificationName("settingBackPressed", object:nil)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.6)
        UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: view.window, cache: true)
        dismissViewControllerAnimated(false, completion:nil)
        UIView.commitAnimations()
    }
    
    func updatePlits() {
        var path = DiallingCodesHelper.documentsDirectory() + "idd_record.plist"
        DiallingCodesHelper.sharedHelper.iddArray.bridgeToObjectiveC().writeToFile(path, atomically: true)
        
        path = DiallingCodesHelper.documentsDirectory() + "cc_record.plist"
        DiallingCodesHelper.sharedHelper.countryCodeArray.bridgeToObjectiveC().writeToFile(path, atomically: true)
        
        path = DiallingCodesHelper.documentsDirectory() + "dcc_record.plist"
        
        DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.sort(<)
        DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.bridgeToObjectiveC().writeToFile(path, atomically: true)
    }
    
    //    #pragma mark - delegates
    
    func popSelection(indexPath:NSIndexPath) {
        
        if preferPopoverController.isPopoverVisible {
            preferPopoverController.dismissPopoverAnimated(true)
            return
        }
        
        let theView = self.settingTableView.cellForRowAtIndexPath(indexPath)
        selectedCell = countriesArray()[indexPath.row]
        
        if selectedCell {
            let preference = DiallingCodesHelper.sharedHelper.preferenceByCode(selectedCell!)
            var selectedIndex = -1
            
            var iddValueArray = String[]()
            for x in 0 .. DiallingCodesHelper.sharedHelper.iddArray.count {
                let iddRecord = DiallingCodesHelper.sharedHelper.iddArray[x]
                if preference == iddRecord.iddCode {
                    selectedIndex = x;
                }
                iddValueArray.append(iddRecord.iddCode)
            }
            preferenceViewController.selectedIndex = selectedIndex
            
            preferenceViewController.dataSource = iddValueArray
            preferPopoverController.delegate = self
            preferPopoverController.passthroughViews = [theView]
            preferPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
            preferPopoverController.wantsDefaultContentAppearance = false
            preferPopoverController.presentPopoverFromRect(theView.bounds, inView:theView, permittedArrowDirections:WYPopoverArrowDirection.Any, animated:true, options:WYPopoverAnimationOptions.FadeWithScale)
        }
    }
    
    func selectorViewDidSelected(selectorView:SelectorTableViewController) {
        if selectorView == preferenceViewController {
            preferPopoverController.dismissPopoverAnimated(true)
            
            let selectedIndex = preferenceViewController.selectedIndex
            if selectedIndex != -1 {
                DiallingCodesHelper.sharedHelper.setPreference((DiallingCodesHelper.sharedHelper.iddArray[selectedIndex]).iddCode, code: selectedCell!)
            }
        }
    }
    
    //  #pragma mark - table view delegate
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int{
        return 3
    }
    
    func tableView(tableView: UITableView!,
        titleForHeaderInSection section: Int) -> String!{
            if section == 0 {
                return "IDD Codes"
            } else if section == 1 {
                return "Country Codes - Enabled"
            } else if section == 2 {
                return "Country Codes - Disabled"
            }
            return ""
    }
    
    func colorForHeader(#section: Int) -> UIColor?{
        if section == 0 {
            return UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        } else if section == 1 {
            return UIColor(red:0.1, green:0.9, blue:0.2, alpha:1.0)
        } else if section == 2 {
            return UIColor(red:1, green:0.4, blue:0.5, alpha:1.0)
        }
        return nil
    }
    
    func tableView(tableView: UITableView!,
        viewForHeaderInSection section: Int) -> UIView!{
            return sectionViewArray![section]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!){
        for section in 0 .. sectionViewArray!.count{
            let sectionView = sectionViewArray![section]
            var offset = sectionView.frame.origin.y - scrollView.contentOffset.y
            if offset < 0 {
                offset = 0
            } else if offset >= 80 {
                offset = 80
            }
            let centerView = centerViewArray![section]
            var frame = centerView.frame
            frame.size.width = 160 + (offset * 0.5);
            centerView.frame = frame
            centerView.alpha = 1 - offset * 0.3 / 80
            centerView.center = CGPointMake(sectionView.frame.size.width / 2, sectionView.frame.size.height / 2)
        }
    }
    
    func tableView(tableView: UITableView!,
        heightForHeaderInSection section: Int) -> CGFloat{
            return 22
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0;
        if (section == 0) {
            numberOfRow = iddArray().count
        }
        else if (section == 1) {
            numberOfRow = countriesArray().count
        }
        else if (section == 2) {
            numberOfRow = disableCountriesArray().count
        }
        if (numberOfRow == 0) {
            sectionViewArray![section].hidden = true
        } else {
            sectionViewArray![section].hidden  = false
        }
        return numberOfRow;
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!,
        canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool{
            return searchBar.text.isEmpty;
    }
    
    func tableView(tableView: UITableView!,
        editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
            if indexPath.section == 2 {
                return UITableViewCellEditingStyle.Insert
            } else {
                return UITableViewCellEditingStyle.Delete;
            }
    }
    
    func tableView(tableView: UITableView!,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath!) {
            let section = indexPath.section;
            if (section == 0) {
                let removingObj = iddArray()[indexPath.row]
                tableView.beginUpdates()
                for i in 0..DiallingCodesHelper.sharedHelper.iddArray.count {
                    if DiallingCodesHelper.sharedHelper.iddArray[i] == removingObj {
                        DiallingCodesHelper.sharedHelper.iddArray.removeAtIndex(i)
                    }
                }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                tableView.endUpdates()
            } else {
                if editingStyle == UITableViewCellEditingStyle.Delete {
                    let removingObj = countriesArray()[indexPath.row]
                    tableView.beginUpdates()
                    DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.insert(removingObj, atIndex: 0)
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    for i in 0..DiallingCodesHelper.sharedHelper.countryCodeArray.count {
                        if DiallingCodesHelper.sharedHelper.countryCodeArray[i] == removingObj {
                            DiallingCodesHelper.sharedHelper.countryCodeArray.removeAtIndex(i)
                        }
                    }
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Automatic)
                    tableView.endUpdates()
                } else if editingStyle == UITableViewCellEditingStyle.Insert {
                    let removingObj = disableCountriesArray()[indexPath.row]
                    tableView.beginUpdates()
                    DiallingCodesHelper.sharedHelper.countryCodeArray.insert(removingObj, atIndex: 0)
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    for i in 0..DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.count {
                        if DiallingCodesHelper.sharedHelper.disabledCountryCodeArray[i] == removingObj {
                            DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.removeAtIndex(i)
                        }
                    }
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Automatic)
                    tableView.endUpdates()
                }
            }
    }
    func doNothing(){
        
    }
    
    func tableView(tableView: UITableView!,
        moveRowAtIndexPath fromIndexPath: NSIndexPath!,
        toIndexPath: NSIndexPath!) {
            let source = fromIndexPath.section
            let des = toIndexPath.section
            if source == 0 && des == 0 {
                let removingObj = DiallingCodesHelper.sharedHelper.iddArray[fromIndexPath.row]
                DiallingCodesHelper.sharedHelper.iddArray.removeAtIndex(fromIndexPath.row)
                DiallingCodesHelper.sharedHelper.iddArray.insert(removingObj, atIndex: toIndexPath.row)
            } else if source != 0 && des != 0 {
                if source == des {
                    switch source{
                    case 1:
                    let removingObj = DiallingCodesHelper.sharedHelper.countryCodeArray[fromIndexPath.row]
                    DiallingCodesHelper.sharedHelper.countryCodeArray.removeAtIndex(fromIndexPath.row)
                    DiallingCodesHelper.sharedHelper.countryCodeArray.insert(removingObj, atIndex: toIndexPath.row)
                    case 2:
                    let removingObj = DiallingCodesHelper.sharedHelper.disabledCountryCodeArray[fromIndexPath.row]
                    DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.removeAtIndex(fromIndexPath.row)
                    DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.insert(removingObj, atIndex: toIndexPath.row)
                    default:
                        doNothing()
                    }

                } else {
                    var removingObj:String = ""
                    switch source{
                    case 1:
                        removingObj = DiallingCodesHelper.sharedHelper.countryCodeArray[fromIndexPath.row]
                    case 2:
                        removingObj = DiallingCodesHelper.sharedHelper.disabledCountryCodeArray[fromIndexPath.row]
                    default:
                        doNothing()
                    }
                    switch des{
                    case 1:
                        DiallingCodesHelper.sharedHelper.countryCodeArray.insert(removingObj, atIndex: toIndexPath.row)
                    case 2:
                        DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.insert(removingObj, atIndex: toIndexPath.row)
                    default:
                        doNothing()
                    }
                    switch source{
                    case 1:
                        DiallingCodesHelper.sharedHelper.countryCodeArray.removeAtIndex(fromIndexPath.row)
                    case 2:
                        DiallingCodesHelper.sharedHelper.disabledCountryCodeArray.removeAtIndex(fromIndexPath.row)
                    default:
                        doNothing()
                    }
                }
            }
            tableView.reloadData()
    }
    
    func tableView(tableView: UITableView!,
        cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
            let MyIdentifier = indexPath.section == 0 ? "IDD" : "CC";
            
            var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier) as? UITableViewCell
            
            if !cell {
                var theCell  = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:MyIdentifier)
                if (indexPath.section == 0) {
                    theCell.textLabel.font = UIFont(name:"HelveticaNeue-Thin", size:26)
                } else {
                    theCell.textLabel.font = UIFont(name:"HelveticaNeue-Thin", size:25)
                }
                theCell.textLabel.adjustsFontSizeToFitWidth = true
                theCell.textLabel.textAlignment = NSTextAlignment.Center
                
                theCell.backgroundColor = UIColor.clearColor()
                cell = theCell
            }
            var theCell:UITableViewCell = cell!
            theCell.textLabel.textColor = colorForHeader(section:indexPath.section)
            if (indexPath.section == 0) {
                theCell.textLabel.text = iddArray()[indexPath.row].iddCode
                
            } else if (indexPath.section == 1) {
                theCell.textLabel.text = DiallingCodesHelper.sharedHelper.countryNameByCode(countriesArray()[indexPath.row])
                
            } else if (indexPath.section == 2) {
                theCell.textLabel.text = DiallingCodesHelper.sharedHelper.countryNameByCode(disableCountriesArray()[indexPath.row])
            }
            return theCell;
    }
    
    func tableView(tableView: UITableView!,
        shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
            if indexPath.section == 1 {
                return true;
            } else {
                return false;
            }
    }
    
    func tableView(tableView: UITableView!,
        didSelectRowAtIndexPath indexPath: NSIndexPath!) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            popSelection(indexPath)
    }
    
    //    #pragma mark - search bar delegate
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        settingTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        searchBar.resignFirstResponder()
    }
    
}
