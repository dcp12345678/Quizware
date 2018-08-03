//
//  ViewQuestionsViewController.swift
//  Quizware
//
//  Created by TechReviews on 2/13/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class VCQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblQuestion: UILabel!
    var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
//        btnEdit.isHidden = true
    }
}

class ViewQuestionsViewController: UITableViewController {

    @IBOutlet var questionsTableView: UITableView!
    var questions: NSMutableSet?
    var sortedQuestions: [Any]?
    var quiz: Quiz?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // don't show the back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        // add a button for them to add another question
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addQuestionWasTapped))
        
        sortedQuestions = questions?.allObjects.sorted { (a, b) -> Bool in
            let a = a as! QuizQuestion
            let b = b as! QuizQuestion
            if a.createDate != nil && b.createDate != nil {
                return a.createDate! < b.createDate!
            }
            return true
        }

        //questionsTableView.separatorColor = UIColor.white
        //questionsTableView.separatorInset = .zero
        //questionsTableView.layoutMargins = .zero

        // this step is done to remove the empty cells from end of table view
        questionsTableView.tableFooterView = UIView()
    }

    @objc func addQuestionWasTapped() {
        performSegue(withIdentifier: "addQuestion", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions == nil ? 0 : questions!.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header"
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as! VCQuestionTableViewCell

        if let quizQuestion = sortedQuestions?[indexPath.row] as? QuizQuestion {
            print("quizQuestion = \(quizQuestion)")
            let text = quizQuestion.questionText!
            cell.lblQuestion.text = "\(text) Section:\(indexPath.section) Row: \(indexPath.row) "
            cell.contentView.tag = indexPath.row
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addQuestion" {
            // store the quiz in the target controller
            (segue.destination as! EditQuestionViewController).quiz = quiz
        }
    }
}
