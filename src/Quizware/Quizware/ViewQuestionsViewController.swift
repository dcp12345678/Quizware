//
//  ViewQuestionsViewController.swift
//  Quizware
//
//  Created by TechReviews on 2/13/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class QuestionTableViewCell : UITableViewCell {
    
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var txtQuestion: UITextView!
}

class ViewQuestionsViewController: UITableViewController {

    @IBOutlet var questionsTableView: UITableView!
    var questions: NSMutableSet?
    var sortedQuestions: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        sortedQuestions = questions?.allObjects.sorted { (a,b) -> Bool in
            let a = a as! QuizQuestion
            let b = b as! QuizQuestion
            return a.createDate! < b.createDate!
        }
        
        questionsTableView.separatorColor = UIColor.white
        questionsTableView.separatorInset = .zero
        questionsTableView.layoutMargins = .zero
        
        // this step is done to remove the empty cells from end of table view
        questionsTableView.tableFooterView = UIView()
        
        questionsTableView.rowHeight = UITableViewAutomaticDimension
        questionsTableView.estimatedRowHeight = 120
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
        return questions == nil ? 0 : questions!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionView", for: indexPath) as! QuestionTableViewCell

        //if let rowData = questions?.allObjects[indexPath.row] as? QuizQuestion {
        if let rowData = sortedQuestions?[indexPath.row] as? QuizQuestion {
            print("rowData = \(rowData)")
            cell.txtQuestion.text = rowData.questionText
            cell.contentView.tag = indexPath.row
        }

        let backgroundView: UIView = {
            let view = UIView()
            let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            view.backgroundColor = color
            view.layer.cornerRadius = 10.0
            return view
        }()
        Helper.pinBackground(backgroundView, to: cell.rootStackView)
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
