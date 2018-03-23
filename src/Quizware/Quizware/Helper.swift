//
//  Helper.swift
//  Quizware
//
//  Created by TechReviews on 1/11/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum CellExpandedState {
    case Expanded
    case Collapsed
}

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            topAnchor.constraint(equalTo: view.topAnchor, constant: -8),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8)
            ])
    }
}

struct Helper {
    static var dummyQuizId: NSManagedObjectID?
    
    static func deleteQuizData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quiz")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    static func saveQuiz(id: NSManagedObjectID?, quizName: String, parentController: UIViewController? = nil) -> Quiz? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        var quiz: Quiz = Quiz()
        if let id = id {
            // fetch the existing quiz so we can update it
            if let obj = managedContext.object(with: id) as? Quiz {
                quiz = obj
            } else {
                if let parentController = parentController {
                    showMessage(parentController: parentController, message: "Could not find existing quiz!")
                }
                print("Could not find existing quiz.")
                return nil
            }
        } else {
            // create a new quiz
            quiz = Quiz(context: managedContext)
        }
        quiz.name = quizName

        // save the quiz to persistence
        do {
            try managedContext.save()
            return quiz
        } catch let error as NSError {
            if let parentController = parentController {
                showMessage(parentController: parentController, message: "Could not save the quiz!")
            }
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    static func loadQuizData(quizNumber: Int) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let quiz = Quiz(context: managedContext)
        quiz.name = "sample quiz " + String(quizNumber)
        
        for i in 0..<5 {
            let quizQuestion = QuizQuestion(context: managedContext)
            quizQuestion.questionText = "This is sample question \(i) for the quiz"
            quizQuestion.createDate = Date()
            quiz.addToQuizQuestion(quizQuestion)
            dummyQuizId = quiz.objectID

            for i in 0..<4 {
                let quizAnswer = QuizAnswer(context: managedContext)
                quizAnswer.answerText = "Answer " + String(i)
                quizQuestion.addToQuizAnswer(quizAnswer)
            }
        }
        
        do {
            try managedContext.save()
            dummyQuizId = quiz.objectID
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func fetchQuizData() -> [NSManagedObject]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Quiz")
        
        do {
            let quizes = try managedContext.fetch(fetchRequest)
            let quizQuestions = quizes[0].mutableSetValue(forKey: "quizQuestion")
            let cnt = quizQuestions.count
            print("cnt = \(cnt)")
            print("\(quizes)")
            return quizes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    static func getQuizQuestions(quizId: NSManagedObjectID) -> NSMutableSet? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let quiz = managedContext.object(with: quizId)
        let quizQuestions = quiz.mutableSetValue(forKey: "quizQuestion")
        return quizQuestions
        
//        let quiz = Quiz()
//        quiz.name = "A Test Quiz"
//        var quizQuestion = QuizQuestion()
//        quizQuestion.questionText = "this is the first question"
//        quiz.addToQuizQuestion(quizQuestion)
//
//        var quizAnswer = QuizAnswer()
//        quizAnswer.answerText = "answer #1"
//        quizQuestion.addToQuizAnswer(quizAnswer)
    }
    
    static func showMessage(parentController: UIViewController, message: String, title: String = "Info") {
        let controller = UIAlertController(
            title: title,
            message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default, handler: nil)
        controller.addAction(okAction)
        parentController.present(controller, animated: true, completion: nil)
    }
    
    static func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }

}
