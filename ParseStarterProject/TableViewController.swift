//
//  TableViewController.swift
//  Photo Sharing
//
//  Created by Swapnil Dhanwal on 26/01/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


class TableViewController: UITableViewController {
    
    var usernames = [""]
    var userids = [""]
    var isfollowing = ["":false]
    
    var refresher = UIRefreshControl()
    
    func refresh()
    {
        print("refreshed")
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            self.usernames.removeAll(keepCapacity: true)
            self.userids.removeAll(keepCapacity: true)
            self.isfollowing.removeAll(keepCapacity: true)
            
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        if let user = object as? PFUser
                        {
                            if user != PFUser.currentUser()
                            {
                                self.usernames.append(user.username! as String)
                                self.userids.append(user.objectId! as String)
                                
                                let query = PFQuery(className: "followers")
                                query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                                query.whereKey("following", equalTo: user.objectId!)
                                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                    
                                    
                                    if let objects = objects
                                    {
                                        if objects.count > 0
                                        {
                                            self.isfollowing[user.objectId! as String] = true
                                        }
                                        else
                                        {
                                            self.isfollowing[user.objectId! as String] = false
                                        }
                                        
                                    }
                                    if self.isfollowing.count == self.usernames.count
                                    {
                                        self.tableView.reloadData()
                                        self.refresher.endRefreshing()
                                    }
                                    
                                    
                                })
                            }
                        }
                    }
                }
            }
            
            print(self.usernames)
            print(self.userids)
            
            
        })

        
    }
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            if error == nil
            {
                print("logged out successfully")
                PFUser.logOut()
                PFUser.currentUser()?.objectId = nil
                self.performSegueWithIdentifier("logout", sender: self)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresher)
        
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            self.usernames.removeAll(keepCapacity: true)
            self.userids.removeAll(keepCapacity: true)
            self.isfollowing.removeAll(keepCapacity: true)
            
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        if let user = object as? PFUser
                        {
                            if user != PFUser.currentUser()
                            {
                                self.usernames.append(user.username! as String)
                                self.userids.append(user.objectId! as String)
                                
                                let query = PFQuery(className: "followers")
                                query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                                query.whereKey("following", equalTo: user.objectId!)
                                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                    
                                    
                                    if let objects = objects
                                    {
                                        if objects.count > 0
                                        {
                                            self.isfollowing[user.objectId! as String] = true
                                        }
                                        else
                                        {
                                            self.isfollowing[user.objectId! as String] = false
                                        }
                                        
                                    }
                                    if self.isfollowing.count == self.usernames.count
                                    {
                                        self.tableView.reloadData()
                                    }

                                    
                                })
                            }
                        }
                    }
                }
            }
            
            print(self.usernames)
            print(self.userids)
            
            
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = usernames[indexPath.row]
        if isfollowing[userids[indexPath.row]] == true
        {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(usernames[indexPath.row])
        
        if isfollowing[userids[indexPath.row]] == false
        {
            
            isfollowing[userids[indexPath.row]] = true
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            cell?.accessoryType = .Checkmark
            
            let following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId!
            following.saveInBackground()
        }
        else
        {
            isfollowing[userids[indexPath.row]] = false
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            cell?.accessoryType = .None
            
            let query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
              
                for object in objects!
                {
                    object.deleteInBackground()
                }
                
            })

            
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
