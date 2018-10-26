//
//  ViewQuizHistoryViewController.swift
//  Quizware
//
//  Created by TechReviews on 10/19/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class QuizResultTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDateTaken: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblTimeTaken: UILabel!
}

class ViewQuizResultsViewController: UITableViewController {

    @IBOutlet weak var lblDateTaken: UILabel!
    @IBOutlet weak var lblScore: UILabel!

    var quiz: Quiz?
    var quizResults: [QuizResult]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        quizResults = quiz?.quizResult?.allObjects as? [QuizResult]
        
        // sort the quiz results so that most recent quiz result is shown first
        if quizResults != nil {
            let sortedQuizResults = quizResults!.sorted { (a, b) -> Bool in
                if a.dateTaken != nil && b.dateTaken != nil {
                    return a.dateTaken! > b.dateTaken!
                }
                return true
            }
            quizResults = sortedQuizResults

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return quiz!.quizResult?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quizResults", for: indexPath) as! QuizResultTableViewCell

        // Configure the cell...
        if let quizResult = quizResults?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.lblDateTaken.text = dateFormatter.string(from: quizResult.dateTaken!)
            dateFormatter.dateFormat = "h:mm a"
            //dateFormatter.amSymbol = "AM"
            //dateFormatter.pmSymbol = "PM"
            cell.lblTimeTaken.text = dateFormatter.string(from: quizResult.dateTaken!)
            cell.lblScore.text = String(Int(Helper.calcQuizScore(forQuizResult: quizResult)))
        }
        return cell
    }


/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
