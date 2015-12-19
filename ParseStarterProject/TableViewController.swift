//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Gil Felot on 16/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    var usernames = [""]
    var userIDs = [""]
    var isFollowing = ["":false]
    
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Refreshing Data")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        refresh()
    }
    
    func refresh() {
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            guard let users = objects else {
                print(error)
                return
            }
            self.usernames.removeAll(keepCapacity: true)
            self.userIDs.removeAll(keepCapacity: true)
            self.isFollowing.removeAll(keepCapacity: true)
            for object in users {
                guard let user = object as? PFUser else {
                    print("Error in user is not an PFUser")
                    return
                }
                if user.objectId != PFUser.currentUser()?.objectId {
                    self.usernames.append(user.username!)
                    self.userIDs.append(user.objectId!)
                    let query = PFQuery(className: "Followers")
                    query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                    query.whereKey("following", equalTo: user.objectId!)
                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        if let objects = objects {
                            if objects.count > 0 {
                                self.isFollowing[user.objectId!] = true
                            } else {
                                self.isFollowing[user.objectId!] = false
                            }
                        }
                        if self.isFollowing.count == self.usernames.count {
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                        }
                    })
                }
            }
            
        })
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("logout", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        let followedObjectID = userIDs[indexPath.row]
        if isFollowing[followedObjectID] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let followedObjectID = userIDs[indexPath.row]
        if isFollowing[followedObjectID] == false {
            isFollowing[followedObjectID] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            let following = PFObject(className: "Followers")
            following["following"] = userIDs[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            following.saveInBackground()
        } else {
            isFollowing[followedObjectID] = false
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            let query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userIDs[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        }
    }
    
}