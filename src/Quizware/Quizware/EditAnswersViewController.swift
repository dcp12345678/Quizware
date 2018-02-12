//
//  EditAnswersViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/18/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

protocol AnswerTableViewCellDelegate {
    func setDeleteButton()
}

class AnswerTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var txtAnswer: UITextView!
    @IBOutlet weak var btnCorrectOrIncorrectAnswer: UIButton!
    @IBOutlet weak var btnSelectAnswer: UIButton!
    var answers: [NSMutableDictionary]?
    var delegate: AnswerTableViewCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        txtAnswer.delegate = self
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // update the answer's text in the answers array
        let index = textView.tag
        answers![index]["text"] = textView.text
    }

    @IBAction func btnSelectAnswerWasTapped(_ sender: Any) {
        if let btn = sender as? UIButton {
            NSLog("row number of selected row is \(btn.tag)")
            let answer = answers![btn.tag]
            let isSelected = answer["isSelected"] as! Bool
            
            // toggle selection state, then set the proper button icon to show whether the
            // answer is selected or unselected (open circle means not selected, checked
            // circle means selected)
            answer["isSelected"] = !isSelected
            if (answer["isSelected"] as! Bool) {
                btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .checkCircle), for: .normal)
            } else {
                btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
            }
            
            // either enable or disable the delete button depending on whether any answers
            // are selected
            delegate?.setDeleteButton()
        }
    }
    
}

class AnswerTableView: UITableView, UITableViewDataSource, UITableViewDelegate, AnswerTableViewCellDelegate {

    let lineItemCellIdentifier = "AnswerLineItem"
    var parentViewController: EditAnswersViewController?
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
                cell.btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .checkCircle), for: .normal)
            } else {
                cell.btnSelectAnswer.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
            }
            cell.btnSelectAnswer.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)

        } else {
            cell.btnSelectAnswer.isHidden = true
        }
        
        // store the row number in the button's tag so when user taps the button, we know which
        // row they've tapped
        cell.btnSelectAnswer.tag = indexPath.row
        cell.answers = answers
        cell.delegate = self

        // if the user is editing the answer table, make the answer text view for this cell editable
        cell.txtAnswer.isEditable = parentViewController!.isEditing
        
        // store the row number in the txtAnswer's tag so when user finishes editing an answer, we know
        // which row in the answers array it corresponds to
        cell.txtAnswer.tag = indexPath.row
        
        return cell
    }
    
    func setDeleteButton() {
        // if at least one answer is selected then enable the delete button,
        // otherwise disable it
        var isAtLeastOneSelected = false
        for answer in answers {
            if (answer["isSelected"] as! Bool) {
                isAtLeastOneSelected = true
                break
            }
        }
        parentViewController?.btnDelete.isEnabled = isAtLeastOneSelected
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

class EditAnswersViewController: UIViewController, AnswerTableViewCellDelegate, UITextViewDelegate {
    
    var questionText: String?
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var answerTableView: AnswerTableView!
    @IBOutlet weak var txtAnswer: UITextView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // don't show the question in landscape mode since it takes up too much room
        if toInterfaceOrientation == .landscapeLeft || toInterfaceOrientation == .landscapeRight {
            txtQuestion.isHidden = true
        }
        else {
            txtQuestion.isHidden = false
        }
    }
    
    func setDeleteButton() {
        // if at least one answer was selected then enable the delete button, otherwise
        // disable it
        var atLeastOneSelected = false
        for answer in answerTableView.answers {
            if (answer["isSelected"] as! Bool) {
                atLeastOneSelected = true
                break
            }
        }
        btnDelete.isEnabled = atLeastOneSelected

    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter answer here"
            textView.textColor = UIColor.lightGray
        }
    }
    
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
        btnDelete.isHidden = true
        btnDone.isHidden = true
        
        // set the delegate for txtAnswer so we can hide/show the placeholder text
        txtAnswer.delegate = self
        
        txtAnswer.text = "Enter answer here"
        txtAnswer.textColor = UIColor.lightGray
        
        // don't show the question in landscape mode since it takes up too much room
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            txtQuestion.isHidden = true
        }
        else {
            txtQuestion.isHidden = false
        }

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
    
    @IBAction func btnDeleteWasTapped(_ sender: Any) {
        // -- delete any selected anwswers --
        // we will make a new answers array and just add the non-selected
        // answers to it
        var newAnswers = [NSMutableDictionary]()
        for answer in answerTableView.answers {
            if !(answer["isSelected"] as! Bool) {
                newAnswers.append(answer)
            }
        }
        answerTableView.answers = newAnswers
        answerTableView.reloadData()
    }
    
    private func addAnswer(isCorrect: Bool) {
        let answer = NSMutableDictionary()
        answer["text"] = txtAnswer.text
        answer["isCorrect"] = isCorrect
        answer["isSelected"] = false
        answerTableView.answers.append(answer)
        answerTableView.reloadData()
        
        // clear the answer text view so they can enter another answer
        txtAnswer.text = ""
        txtAnswer.endEditing(true)
    }
    
    @IBAction func btnEditWasTapped(_ sender: Any) {
        isEditing = true
        self.btnEdit.isHidden = true
        self.btnDelete.isHidden = false
        self.btnDelete.isEnabled = false
        self.btnDone.isHidden = false
        
        answerTableView.reloadData()
    }
    
    @IBAction func btnDoneWasTapped(_ sender: Any) {
        isEditing = false
        self.btnEdit.isHidden = false
        self.btnDelete.isHidden = true
        self.btnDone.isHidden = true
        for answer in answerTableView.answers {
            answer["isSelected"] = false
        }
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
