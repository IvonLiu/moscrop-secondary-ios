//
//  TeacherTableViewController.swift
//  MoscropSecondary
//
//  Created by Jason Wong on 2015-10-06.
//  Copyright (c) 2015 Ivon Liu. All rights reserved.
//

import UIKit
import Parse
import Foundation

class TeacherTableViewController: UITableViewController, UISearchBarDelegate {
    var teachers = [PFObject]()
    var wifiChecked = true
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Swipe Gesture
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        leftSwipe.direction = .Left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // Retrieve NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("WifiOnly") != nil) {
            wifiChecked = defaults.boolForKey("WifiOnly")
        }
        loadTeachers()
        
    }
    func handleSwipe(sender:UISwipeGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        vc.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        if (sender.direction == .Left) {
            vc.selectedIndex = 4
            self.presentViewController(vc, animated: true, completion: nil)
        }
        if (sender.direction == .Right) {
            vc.selectedIndex = 2
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        searchBar.delegate = self
    }
    
    // populates teachers array with parse data
    func loadTeachers() {
        
        let query = PFQuery(className:"teachers")
        query.includeKey("Dept")
        query.orderByAscending("LastName")
        
        if Utils.checkConnection() == NetworkStatus.WiFiConnection && Utils.isConnectedToNetwork(){
            query.cachePolicy = .NetworkOnly
        } else if Utils.checkConnection() == NetworkStatus.WWANConnection {
            if self.wifiChecked {
                query.cachePolicy = .CacheOnly
            } else {
                query.cachePolicy = .NetworkOnly
            }
        } else {
            query.cachePolicy = .CacheOnly
        }
        print(query.hasCachedResult)
        if self.searchBar.text != "" {
            
            query.whereKey("searchText", containsString: self.searchBar.text!.lowercaseString)
        }
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if objects == nil || objects!.count == 0 {
                    query.clearCachedResult()
                }
                self.teachers.removeAll(keepCapacity: false)
                
                self.teachers = Array(objects!.generate())
                
                
                self.tableView.reloadData()
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            
        }
        
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        loadTeachers()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        loadTeachers()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        loadTeachers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.teachers.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("teacher", forIndexPath: indexPath) as! TeacherTableViewCell
        let teacher = teachers[indexPath.row]
        
        if let prefix = teacher["Prefix"] as? String{
            if let firstName = teacher["FirstName"] as? String{
                if let lastName = teacher["LastName"] as? String{
                    var teacherName = prefix + ". " + String(firstName[firstName.startIndex.advancedBy(0)]) + ". " + lastName
                    cell.teacherNameLabel.text = teacherName
                    
                    cell.teacherName = teacherName
                    
                }
            }
            
            
        }
        //        print(teacher["searchText"])
        
        if let dept = teacher["Department"] as? String{
            cell.fieldWorkLabel.text = dept
            cell.department = dept
            var url : NSURL?
            if let deptObj = teacher["Dept"] as? PFObject{
                if let icon = deptObj["image"] as? String{
                    url = NSURL(string: icon)
                    //                                print(url)
                }
            }
            
            
            if url != nil {
                
                cell.fieldImage.layer.cornerRadius = 21
                
                cell.fieldImage.kf_setImageWithURL(url!, placeholderImage: UIImage (named: "default_teacher"))
                
            }
            
            
            
            
        }
        if let rooms = teacher["Rooms"] as? Array<String>{
            cell.rooms = rooms
        } else {
            cell.rooms = []
        }
        if let email = teacher["Email"] as? String {
            cell.email = email
        } else {
            cell.email = ""
        }
        if let website = teacher["Sites"] as? String{
            cell.website = website
        } else {
            cell.website = ""
        }
        
        
        // cell.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the cell...
        
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 58.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TeacherTableViewCell
        
        var message = ""
        if cell.department != "" {
            message += "\n Department \n" + cell.department
        }
        if !cell.rooms.isEmpty {
            message += "\n\n Room \n" + cell.combineRooms()
        }
        if cell.email != "" {
            
            message += "\n\n Email \n" + cell.email
        }
        
        if cell.website != "" {
            message += "\n\n Site \n" + cell.website
        }
        let alert = UIAlertController(title: cell.teacherName, message: message, preferredStyle: .Alert)
        
        if cell.email != "" {
            let emailAction = UIAlertAction(title: "Email Now", style: .Default) { (action) -> Void in
                //direct them to sending email
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                // does not work in simulator; only on device
                
                let url = NSURL(string: "mailto:" + cell.email)
                UIApplication.sharedApplication().openURL(url!)
            }
            alert.addAction(emailAction)
        }
        
        if cell.website != "" {
            let siteAction = UIAlertAction(title: "Enter Site", style: .Default) { (action) -> Void in
                //direct them to site
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                UIApplication.sharedApplication().openURL(NSURL(string: cell.website)!)
                
            }
            alert.addAction(siteAction)
        }
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default) {(action) -> Void in
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            
        }
        
        
        alert.addAction(defaultAction)
    
        
        presentViewController(alert, animated: true, completion: nil)
        if ThemeManager.currentTheme() == ThemeType.Black {
            alert.view.tintColor = UIColor.blackColor()
            
        }
        
    }
    
    
    
}



