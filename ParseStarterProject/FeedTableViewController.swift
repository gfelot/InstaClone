//
//  FeedTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Gil Felot on 21/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    
    var messages = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    var users = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            guard let users = objects else {
                print(error)
                return
            }
            self.messages.removeAll(keepCapacity: true)
            self.users.removeAll(keepCapacity: true)
            self.imageFiles.removeAll(keepCapacity: true)
            self.usernames.removeAll(keepCapacity: true)
            for object in users {
                if let user = object as? PFUser {
                    self.users[user.objectId!] = user.username!
                }
            }
            
            let getFolllowedUsersQuery = PFQuery(className: "Followers")
            getFolllowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            getFolllowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                guard let objects = objects else {
                    print(error)
                    return
                }
                for object in objects {
                    let followedUser = object["following"] as! String
                    let query = PFQuery(className: "Post")
                    query.whereKey("userID", equalTo: followedUser)
                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        guard let objects = objects else {
                            print(error)
                            return
                        }
                        for object in objects {
                            self.messages.append(object["message"] as! String)
                            self.imageFiles.append(object["imageFile"] as! PFFile)
                            self.usernames.append(self.users[object["userID"] as! String]!)
                            
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
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
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cell
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            guard let dlImage = UIImage(data: data!) else {
                print(error)
                return
            }
            myCell.postedImage.image = dlImage
        }
        
        myCell.postedImage.image = UIImage(named: "iu.png")
        myCell.userName.text = usernames[indexPath.row]
        myCell.message.text = messages[indexPath.row]
        
        return myCell
    }
    
}
