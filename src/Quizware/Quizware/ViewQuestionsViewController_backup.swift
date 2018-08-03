//
//  ViewQuestionsViewController.swift
//  Quizware
//
//  Created by TechReviews on 2/13/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class VCQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var txtQuestion: UITextView!
    var isExpanded: Bool = false
    @IBOutlet weak var answerTableView: VCAnswerTableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        btnEdit.isHidden = true
    }
}

class VCAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var lblAnswer: UILabel!
}

class VCAnswerTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var answerArray = [String]()

    let answerCellIdentifier = "AnswerTableViewCell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: answerCellIdentifier, for: indexPath)
            as! VCAnswerTableViewCell

        let row = indexPath.row
        cell.lblAnswer.text = answerArray[row]
        cell.lblAnswer.layer.masksToBounds = true
        cell.lblAnswer.layer.cornerRadius = 0.0
        cell.lblAnswer.layer.borderWidth = 0.0
        cell.lblAnswer.layer.borderColor = UIColor.white.cgColor
        
        let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        cell.backgroundColor = color

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerArray.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = indexPath.row
        print(answerArray[row])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as! VCQuestionTableViewCell

        //if let rowData = questions?.allObjects[indexPath.row] as? QuizQuestion {
        if let quizQuestion = sortedQuestions?[indexPath.row] as? QuizQuestion {
            print("quizQuestion = \(quizQuestion)")
            cell.txtQuestion.text = quizQuestion.questionText
            cell.contentView.tag = indexPath.row

            if cell.answerTableView.answerArray.count == 0 {
                // get the answers for the question
                if let answers = Helper.getQuizAnswers(forQuizQuestionId: quizQuestion.objectID) {
                    cell.answerTableView.answerArray = []
                    for case let answer as QuizAnswer in answers {
                        print("answer = \(answer)")
                        cell.answerTableView.answerArray.append(answer.answerText ?? "")
                    }
                }
            }
        }

        // add a gesture recognizer for when they tap the cell
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewWasTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)

        // set the background color of the stackview and also the corner radius
        let backgroundView: UIView = {
            let view = UIView()
            let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            view.backgroundColor = color
            view.layer.cornerRadius = 10.0
            return view
        }()
        Helper.pinBackground(backgroundView, to: cell.rootStackView)

        cell.answerTableView.dataSource = cell.answerTableView
        cell.answerTableView.delegate = cell.answerTableView
        
        cell.answerTableView.estimatedRowHeight = 80
        cell.answerTableView.rowHeight = UITableViewAutomaticDimension

        // add a random number of answers
//        if cell.answerTableView.answerArray.count == 0 {
//            cell.answerTableView.answerArray = []
//            let numAnswers = max(Int(arc4random_uniform(9)), 1)
//            for i in 1...numAnswers {
//                cell.answerTableView.answerArray.append("this is answer #\(i)" + (i % 2 == 0 ? ". It is really, really, long" : ""))
//            }
//        }


        // don't show the detail stack view (which contains the question's answers) initially; it will get
        // shown if they tap the question cell to expand its detail
        cell.detailStackView.isHidden = true

        // this step is done to remove the empty cells from end of table view
        cell.answerTableView.tableFooterView = UIView()

        return cell
    }

    @objc func cellViewWasTapped(_ sender: UITapGestureRecognizer) {
        let indexPath = NSIndexPath(row: (sender.view?.tag)!, section: 0) as IndexPath
        if let cell = questionsTableView.cellForRow(at: indexPath as IndexPath) as? VCQuestionTableViewCell {
            // if cell is expanded, then collapse it, otherwise, expand it
            expandOrCollapseCell(at: indexPath, targetState: cell.isExpanded ? CellExpandedState.Collapsed : CellExpandedState.Expanded)
            questionsTableView.beginUpdates()
            questionsTableView.endUpdates()

            // scroll to the row the user tapped
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }

    private func expandOrCollapseCell(at indexPath: IndexPath, targetState: CellExpandedState) {
        if let cell = questionsTableView.cellForRow(at: indexPath as IndexPath) as? VCQuestionTableViewCell {
            let rowData = sortedQuestions![indexPath.row] as! QuizQuestion
            let id = rowData.objectID

            if targetState == .Expanded {

                //
                // we need to expand the cell's detail view
                //

                cell.isExpanded = true

                // store the row index in the buttons' tags so we know what questions the buttons
                // are associated with
//                cell.btnTakeTest.tag = indexPath.row
//                cell.btnViewHistory.tag = indexPath.row
//                cell.btnDelete.tag = indexPath.row
//                cell.btnEdit.tag = indexPath.row
//
                UIView.animate(withDuration: 0.2) {
                    cell.detailStackView.isHidden = false
                    cell.btnEdit.isHidden = false
                    cell.btnEdit.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
                    cell.btnEdit.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
                    cell.btnEdit.setTitleColor(UIColor.white, for: .normal)
                }

            } else {
                // collapse the cell's detail view
                cell.detailStackView.isHidden = true
//                expandedQuizIds.remove(id)
                cell.isExpanded = false
                //cell.answerTableViewHeight.constant = 0
                
                cell.btnEdit.isHidden = true
            }
        }
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
