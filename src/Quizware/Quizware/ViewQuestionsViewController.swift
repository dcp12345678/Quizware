//
//  ViewQuestionsViewController.swift
//  Quizware
//
//  Created by TechReviews on 2/13/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit
import CoreData

struct Question {
    var questionText: String
    var answers: [String]
    var isExpanded = true
}

class VCAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAnswer: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
//        btnEdit.isHidden = true
    }
}

class ViewQuestionsViewController: UITableViewController {

    @IBOutlet var questionsTableView: UITableView!
    var questions: NSMutableSet?
    var sortedQuestions = [Question]()
    var quiz: Quiz?

    //var answers: [ NSManagedObjectID: [Any]] = [ NSManagedObjectID: [Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // don't show the back button
        self.navigationItem.setHidesBackButton(true, animated: true)

        // add a button for them to add another question
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addQuestionWasTapped))

        let tmpQuestions = questions?.allObjects.sorted { (a, b) -> Bool in
            let a = a as! QuizQuestion
            let b = b as! QuizQuestion
            if a.createDate != nil && b.createDate != nil {
                return a.createDate! < b.createDate!
            }
            return true
        }

        for case let question as QuizQuestion in tmpQuestions! {
            var questionToAdd = Question(questionText: question.questionText!, answers: [], isExpanded: true)
            if let a = Helper.getQuizAnswers(forQuizQuestionId: question.objectID) {
                for case let answer as QuizAnswer in a {
                    questionToAdd.answers.append(answer.answerText!)
                }
            }
            sortedQuestions.append(questionToAdd)
        }

//        for case let question as Question in sortedQuestions! {
//            let a = Helper.getQuizAnswers(forQuizQuestionId: question.objectID)
//            answers[question.objectID] = a?.allObjects
//        }

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
        return sortedQuestions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !sortedQuestions[section].isExpanded {
            return 0
        }
        return sortedQuestions[section].answers.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tag = section
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)

        return button

//        let label = UILabel()
//        label.text = (sortedQuestions?[section] as? QuizQuestion)?.questionText
//        label.backgroundColor = UIColor.lightGray
//        return label
    }

    @objc func handleExpandClose(button: UIButton) {
        print("Trying to expand and close section...")

        let section = button.tag

        var indexPaths = [IndexPath]()
        for i in 0..<sortedQuestions[section].answers.count {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        
        sortedQuestions[section].isExpanded = !sortedQuestions[section].isExpanded
        
        button.setTitle(sortedQuestions[section].isExpanded ? "Close" : "Open", for: .normal)
        
        if sortedQuestions[section].isExpanded {
            tableView.insertRows(at: indexPaths, with: .fade)
            button.titleLabel?.text = "Close"
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
            button.titleLabel?.text = "Open"
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerTableViewCell", for: indexPath) as! VCAnswerTableViewCell

        // Get the answer using the indexPath.section and indexPath.row. The indexPath.section
        // gets us the question we are on, and the indexPath.row gets us the answer for that
        // quiz question.
        cell.lblAnswer.text = sortedQuestions[indexPath.section].answers[indexPath.row]
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
