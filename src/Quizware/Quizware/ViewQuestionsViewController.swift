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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class VCAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var txtAnswer: UITextView!
}

class ViewQuestionsViewController: UITableViewController {

    @IBOutlet var questionsTableView: UITableView!
    var questions: NSMutableSet?
    var sortedQuestions: [Any]?
    var quiz: Quiz?
    var selectedQuestion: QuizQuestion?

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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneWasTapped))

        sortedQuestions = questions?.allObjects.sorted { (a, b) -> Bool in
            let a = a as! QuizQuestion
            let b = b as! QuizQuestion
            if a.createDate != nil && b.createDate != nil {
                return a.createDate! < b.createDate!
            }
            return true
        }

        questionsTableView.separatorColor = UIColor.white
        questionsTableView.separatorInset = .zero
        questionsTableView.layoutMargins = .zero

        // this step is done to remove the empty cells from end of table view
        questionsTableView.tableFooterView = UIView()

        questionsTableView.rowHeight = UITableViewAutomaticDimension
        questionsTableView.estimatedRowHeight = 120
    }

    @objc func addQuestionWasTapped() {
        performSegue(withIdentifier: "addQuestion", sender: self)
    }
    
    @objc func doneWasTapped() {
        performSegue(withIdentifier: "goToMainScreen", sender: self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionView", for: indexPath) as! VCQuestionTableViewCell

        if let quizQuestion = sortedQuestions?[indexPath.row] as? QuizQuestion {
            print("quizQuestion = \(quizQuestion)")
            cell.lblQuestion.text = quizQuestion.questionText
            cell.lblQuestion.textColor = UIColor.white
            cell.contentView.tag = indexPath.row
            cell.contentView.backgroundColor = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            cell.contentView.superview?.backgroundColor = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuestion = sortedQuestions![indexPath.row] as? QuizQuestion
        performSegue(withIdentifier: "editAnswers", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addQuestion" {
            // store the quiz in the target controller
            (segue.destination as! EditQuestionViewController).quiz = quiz
        } else if segue.identifier == "editAnswers" {
            (segue.destination as! EditAnswersViewController).quiz = quiz
            (segue.destination as! EditAnswersViewController).quizQuestion = selectedQuestion
        }
    }
}
