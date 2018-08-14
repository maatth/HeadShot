//
//  FaceTableViewController.swift
//  HeadShot
//
//  Created by Maat on 19/06/2018.
//  Copyright © 2018 Maat. All rights reserved.
//

import UIKit

class FaceTableViewController: UITableViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //loadSampleFaces()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameModel.faces.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaceTableViewCellID", for: indexPath) as! FaceTableViewCell
        
        let face = gameModel.faces[indexPath.row]
        
        cell.faceImage1.image = face.photo1
        cell.nameLabel.text = face.name
        cell.isEnemyLabel.text = face.isEnemy ? "Enemy" : "Friend"

        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFace" {
            let faceDetailViewController = segue.destination as! FaceDetailViewController
            if let selectedFaceCell = sender as? FaceTableViewCell {
                let indexPath = tableView.indexPath(for: selectedFaceCell)!
                let selectedFace = gameModel.faces[indexPath.row]
                faceDetailViewController.face = selectedFace
            }
        } else if segue.identifier == "AddFace" {
            print("Adding new face.")
        }
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? FaceDetailViewController, let face = sourceViewController.face {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                gameModel.faces[selectedIndexPath.row] = face
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new face.
                let newIndexPath = IndexPath(row: gameModel.faces.count, section: 0)
                
                gameModel.faces.append(face)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the meals.
            //saves()
        }
    }

}
