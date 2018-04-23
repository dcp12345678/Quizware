//
//  EditQuestionViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/18/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class EditQuestionViewController: UIViewController {

    public var quiz: Quiz?
    
    public var quizQuestion : QuizQuestion?
    
    @IBOutlet weak var txtQuestion: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "editAnswers" {
                quizQuestion = Helper.saveQuizQuestion(questionId: nil, quizId: quiz!.objectID, questionText: txtQuestion.text)
                return quizQuestion != nil
            }
        }
        return false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAnswers" {
            (segue.destination as! EditAnswersViewController).quizQuestion = quizQuestion
            (segue.destination as! EditAnswersViewController).quiz = quiz
        }
    }

}
