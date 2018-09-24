//
//  EditQuizViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/15/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class EditQuizViewController: UIViewController {

    var quiz: Quiz?
    var isNew = false
    
    @IBOutlet weak var txtQuizName: UITextField!
    
    @IBAction func btnNextWasTapped(_ sender: Any) {
        if isNew {
            // if it's a new quiz, then we take them to the screen to
            // create the first question
            performSegue(withIdentifier: "editQuestion", sender: self)
        } else {
            // it's not a new quiz, so just take them to the screen
            // which shows them the exiting questions
            performSegue(withIdentifier: "viewQuestions", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let quiz = quiz {
            self.title = "Edit Quiz"
            txtQuizName.text = quiz.name
        } else {
            self.title = "Create New Quiz"
            isNew = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        quiz = Helper.saveQuiz(quizId: quiz == nil ? nil : quiz!.objectID, quizName: txtQuizName.text!.trimmingCharacters(in: .whitespacesAndNewlines))

        if segue.identifier == "editQuestion" {
            // store the quiz in the target controller
            (segue.destination as! EditQuestionViewController).quiz = quiz
        } else if segue.identifier == "viewQuestions" {
            // store the quiz in the target controller
            (segue.destination as! ViewQuestionsViewController).quiz = quiz
            (segue.destination as! ViewQuestionsViewController).questions = quiz!.mutableSetValue(forKey: "quizQuestion")
}

    }

}
