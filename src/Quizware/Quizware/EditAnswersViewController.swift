//
//  EditAnswersViewController.swift
//  Quizware
//
//  Created by TechReviews on 1/18/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit

class EditAnswersViewController: UIViewController {

    var questionText: String?
    @IBOutlet weak var txtQuestion: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let questionText = questionText {
            txtQuestion.text = questionText
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddAnswerWasTapped(_ sender: Any) {
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
