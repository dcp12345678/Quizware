//
//  ViewQuestionsViewController.swift
//  Quizware
//
//  Created by TechReviews on 2/13/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class VCQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var txtQuestion: UITextView!
    var isExpanded: Bool = false
    @IBOutlet weak var answerTableView: VCAnswerTableView!
    @IBOutlet weak var answerTableViewHeight: NSLayoutConstraint!
}

class VCAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var txtAnswer: UITextView!
}

class VCAnswerTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var answerArray = [String]()

    let answerCellIdentifier = "AnswerTableViewCell"

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: answerCellIdentifier, for: indexPath)
        as! VCAnswerTableViewCell

        let row = indexPath.row
        cell.txtAnswer.text = answerArray[row]
        cell.txtAnswer.layer.cornerRadius = 15.0
        cell.txtAnswer.layer.borderWidth = 2.0
        cell.txtAnswer.layer.borderColor = UIColor.white.cgColor

        //cell.lblProductName?.text = productInfoArray[row].name
        //cell.lblProductCount?.text = String(describing: productInfoArray[row].count)

        let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        cell.backgroundColor = color

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerArray.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addQuestionOnPress))

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

    @objc func addQuestionOnPress() {
        //performSegue(withIdentifier: "viewQuestions", sender: self)
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

        // add a gesture recognizer for when∫ they tap the cell
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)

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

        // add a random number of answers
//        if cell.answerTableView.answerArray.count == 0 {
//            cell.answerTableView.answerArray = []
//            let numAnswers = max(Int(arc4random_uniform(9)), 1)
//            for i in 1...numAnswers {
//                cell.answerTableView.answerArray.append("this is answer #\(i)" + (i % 2 == 0 ? ". It is really, really, long" : ""))
//            }
//        }


        // don't show the answer table view (which contains the question's answers) initially; it will get
        // shown if they tap the question cell to expand its detail
        cell.answerTableView.isHidden = true

        // this step is done to remove the empty cells from end of table view
        cell.answerTableView.tableFooterView = UIView()

        return cell
    }

    @objc func cellViewTapped(_ sender: UITapGestureRecognizer) {
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
                    cell.answerTableView.isHidden = false
                    cell.answerTableViewHeight.constant = CGFloat(65 * cell.answerTableView.answerArray.count)
                }

            } else {
                // collapse the cell's detail view
                cell.answerTableView.isHidden = true
//                expandedQuizIds.remove(id)
                cell.isExpanded = false
                cell.answerTableViewHeight.constant = 0
            }
        }
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
