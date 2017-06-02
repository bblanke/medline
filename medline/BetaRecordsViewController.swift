//
//  RecordsViewController.swift
//  medline
//
//  Created by Bailey Blankenship on 5/23/17.
//  Copyright © 2017 Bailey Blankenship. All rights reserved.
//

import UIKit
import CoreData

class BetaRecordsViewController: UITableViewController {
    
    // MARK: - Globals
    
    // Date Format
    var dateFormatter : DateFormatter! = nil
    
    // Persistence
    var betaReadings : [BetaReading] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Selected stuff
    var selected : Int?
    
    
    weak var recordDelegate : RecordDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE',' MMM d 'at' h:mm a"
        
        loadReadings()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Persistence
    
    func loadReadings(){
        let poRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BetaReading")
        poRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        var betaReadings : [BetaReading]!
        
        do{
            betaReadings = try context.fetch(poRequest) as! [BetaReading]
        } catch {
            print("fetching failed")
        }
        
        self.betaReadings = betaReadings
        
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betaReadings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        
        let reading = betaReadings[indexPath.row]
        
        cell.textLabel?.text = reading.shortName ?? "Unnamed"
        
        if let timestamp = reading.timestamp {
            cell.detailTextLabel?.text = dateFormatter.string(from: timestamp as Date)
        } else {
            cell.detailTextLabel?.text = "Timestamp not recorded"
        }
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.light
        cell.selectionStyle = .none
        
        if let selectedRecord = selected {
            if indexPath.row == selectedRecord {
                cell.textLabel?.textColor = UIColor.primary
                cell.backgroundColor = UIColor.light
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        recordDelegate?.didSelectBetaReading(reading: betaReadings[indexPath.row])
        tableView.reloadData()
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if let selectedRecord = selected{
            return indexPath.row != selectedRecord
        } else {
            return true
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(betaReadings[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            betaReadings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
