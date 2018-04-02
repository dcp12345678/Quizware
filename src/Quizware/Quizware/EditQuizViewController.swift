//
//  EditQuizViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/15/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class EditQuizViewController: UIViewController {

    private var quiz: Quiz?
    
    @IBOutlet weak var txtQuizName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Create New Quiz"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "editQuestion" {
                quiz = Helper.saveQuiz(quizId: nil, quizName: txtQuizName.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                return quiz != nil
            }
        }
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editQuestion" {
            // store the quiz in the target controller
            (segue.destination as! EditQuestionViewController).quiz = quiz
        }

    }

}
