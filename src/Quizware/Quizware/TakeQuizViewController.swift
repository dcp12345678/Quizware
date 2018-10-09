//
//  TakeQuizViewController.swift
//  Quizware
//
//  Created by TechReviews on 9/26/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

protocol PickAnswerTableViewCellDelegate {
    func loadQuestion()
    var questionIndex: Int { get set }
}

class PickAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAnswer: UILabel!
}

class PickAnswerTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    var answers: [QuizAnswer]?
    let pickAnswerCellIdentifier = "PickAnswer"
    var pickAnswerDelegate: PickAnswerTableViewCellDelegate?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let answers = answers {
            return answers.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pickAnswerCellIdentifier, for: indexPath) as! PickAnswerTableViewCell

        if let answers = answers {
            cell.lblAnswer.text = answers[indexPath.row].answerText
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var pickAnswerDelegate = pickAnswerDelegate {
            pickAnswerDelegate.questionIndex = pickAnswerDelegate.questionIndex + 1
            pickAnswerDelegate.loadQuestion()
        }
    }
}


class TakeQuizViewController: UIViewController, PickAnswerTableViewCellDelegate {
    var quiz: Quiz?
    var questionIndex = 0
    var questions: [QuizQuestion]?
    @IBOutlet weak var tblAnswers: UITableView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnPreviousQuestion: UIButton!
    @IBOutlet weak var answerTableView: PickAnswerTableView!
    @IBOutlet weak var btnNextQuestion: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        btnPreviousQuestion.setTitle(String.fontAwesomeIcon(name: .arrowCircleLeft), for: .normal)
        btnPreviousQuestion.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)

        btnNextQuestion.setTitle(String.fontAwesomeIcon(name: .arrowCircleRight), for: .normal)
        btnNextQuestion.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)


        questions = (quiz?.mutableSetValue(forKey: "quizQuestion").allObjects as! [QuizQuestion])
        questions = questions!.sorted { (a, b) -> Bool in
            if a.createDate != nil && b.createDate != nil {
                return a.createDate! < b.createDate!
            }
            return true
        }

        answerTableView.delegate = answerTableView
        answerTableView.pickAnswerDelegate = self
        answerTableView.dataSource = answerTableView

        answerTableView.estimatedRowHeight = 100.0
        answerTableView.rowHeight = UITableViewAutomaticDimension

        loadQuestion()
        setButtons()
    }

    override func viewDidLayoutSubviews() {
        lblQuestion.sizeToFit()
    }

    func setButtons() {
        if let questions = questions {
            btnNextQuestion.isEnabled = questionIndex + 1 < questions.count
            btnPreviousQuestion.isEnabled = questionIndex - 1 >= 0
        }
    }

    func loadQuestion() {
        if let questions = questions {
            if questionIndex < questions.count {
                lblQuestion.text = questions[questionIndex].questionText

                if let answers = Helper.getQuizAnswers(forQuizQuestionId: questions[questionIndex].objectID) {
                    answerTableView.answers = answers

                    answerTableView.reloadData()
                    answerTableView.beginUpdates()
                    answerTableView.endUpdates()

                }

            }
        }
    }

    @IBAction func btnNextQuestionWasTapped(_ sender: Any) {
        questionIndex = questionIndex + 1
        loadQuestion()
        setButtons()
    }

    @IBAction func btnPreviousQuestionWasTapped(_ sender: Any) {
        questionIndex = questionIndex - 1
        loadQuestion()
        setButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
