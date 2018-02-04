//
//  EditAnswersViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/18/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var txtAnswer: UITextView!
    @IBOutlet weak var btnCorrectOrIncorrectAnswer: UIButton!
    @IBOutlet weak var btnSelectAnswer: UIButton!
    var answers: [NSMutableDictionary]?
    
    @IBAction func btnSelectAnswerWasTapped(_ sender: Any) {
        if let btn = sender as? UIButton {
            NSLog("row number of selected row is \(btn.tag)")
            let answer = answers![btn.tag]
            let isSelected = answer["isSelected"] as! Bool
            
            // toggle selection state, then set the proper button icon
            answer["isSelected"] = !isSelected
            if (answer["isSelected"] as! Bool) {
                btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circle), for: .normal)
            } else {
                btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
            }
            //btnSelectAnswer.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        }
    }
    
}

class AnswerTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    let lineItemCellIdentifier = "AnswerLineItem"
    var parentViewController: UIViewController?
    var answers = [NSMutableDictionary]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: lineItemCellIdentifier, for: indexPath) as! AnswerTableViewCell
        let answer = answers[indexPath.row]
        cell.txtAnswer.text = answer["text"] as? String
        if let isCorrect = answer["isCorrect"] as? Bool {
            if isCorrect {
                cell.btnCorrectOrIncorrectAnswer.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
                cell.btnCorrectOrIncorrectAnswer.setTitleColor(UIColor.green, for: .normal)
                cell.btnCorrectOrIncorrectAnswer.setTitle(String.fontAwesomeIcon(name: .check), for: .normal)
            } else {
                cell.btnCorrectOrIncorrectAnswer.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
                cell.btnCorrectOrIncorrectAnswer.setTitleColor(UIColor.red, for: .normal)
                cell.btnCorrectOrIncorrectAnswer.setTitle(String.fontAwesomeIcon(name: .remove), for: .normal)
            }
        }

        // only show the button for selecting an answer if we are in edit mode
        if parentViewController!.isEditing {
            cell.btnSelectAnswer.isHidden = false
            if (answer["isSelected"] as! Bool) == true {
                cell.btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circle), for: .normal)
            } else {
                cell.btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
            }
            cell.btnSelectAnswer.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)

        } else {
            cell.btnSelectAnswer.isHidden = true
        }
        
        // store the row number in the button so when user taps the button, we know which
        // row they've tapped
        cell.btnSelectAnswer.tag = indexPath.row
        cell.answers = answers

        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete logic goes here
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)")
    }
    
}

class EditAnswersViewController: UIViewController {

    var questionText: String?
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var answerTableView: AnswerTableView!
    @IBOutlet weak var txtAnswer: UITextView!    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let questionText = questionText {
            txtQuestion.text = questionText
        }
        
        answerTableView.delegate = answerTableView
        answerTableView.dataSource = answerTableView
        answerTableView.parentViewController = self
        
        // create button for cancelling the edit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                action: #selector(doneOnPress))
        
        for answer in answerTableView.answers {
            answer["isSelected"] = false
        }
        
        isEditing = false
    }

    @objc func doneOnPress() {
        //Helper.showMessage(parentController: self, message: "Cancel button tapped!")
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddCorrectAnswerWasTapped(_ sender: Any) {
        addAnswer(isCorrect: true)
    }
    
    @IBAction func btnAddIncorrectAnswerWasTapped(_ sender: Any) {
        addAnswer(isCorrect: false)
    }
    
    private func addAnswer(isCorrect: Bool) {
        let answer = NSMutableDictionary()
        answer["text"] = txtAnswer.text
        answer["isCorrect"] = isCorrect
        answer["isSelected"] = false
        answerTableView.answers.append(answer)
        answerTableView.reloadData()
    }
    
    @IBAction func btnEditWasTapped(_ sender: Any) {
        isEditing = true
        answerTableView.reloadData()
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
