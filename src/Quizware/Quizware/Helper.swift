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

public extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
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

    static func deleteQuizData(quizId: NSManagedObjectID) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<Quiz>(entityName: "Quiz")
        fetchRequest.predicate = NSPredicate(format: "self == %@", quizId)

        do {
            let resultdata = try managedContext.fetch(fetchRequest)
            if let objectToDelete = resultdata.first {
                managedContext.delete(objectToDelete)
                try managedContext.save() // Save the delete action
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    static func deleteQuizAnswer(answerId: NSManagedObjectID?, parentController: UIViewController? = nil) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate, let answerId = answerId else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        if let objToDelete = managedContext.object(with: answerId) as? QuizAnswer {

            // delete the quiz question from persistence
            do {
                managedContext.delete(objToDelete)
                try managedContext.save()
            } catch let error as NSError {
                if let parentController = parentController {
                    showMessage(parentController: parentController, message: "Could not delete the quiz question!")
                }
                print("Could not delete the quiz question. \(error), \(error.userInfo)")
            }
        }
    }

    static func saveQuizAnswer(answerId: NSManagedObjectID?, answerText: String, isCorrectAnswer: Bool, quizQuestionId: NSManagedObjectID, parentController: UIViewController? = nil) -> QuizAnswer? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        var quizAnswer = QuizAnswer()

        if let answerId = answerId {
            // fetch the existing quiz answer so we can update it
            if let obj = managedContext.object(with: answerId) as? QuizAnswer {
                quizAnswer = obj
            } else {
                if let parentController = parentController {
                    showMessage(parentController: parentController, message: "Could not find existing quiz answer!")
                }
                print("Could not find existing quiz answer.")
                return nil
            }
        } else {
            // create a new quiz answer
            quizAnswer = QuizAnswer(context: managedContext)
            quizAnswer.createDate = Date()

            // it's a new quiz answer, so we need to add it to the quiz question

            // get the associated quiz question for the quiz answer
            let quizQuestion = managedContext.object(with: quizQuestionId) as! QuizQuestion

            // add the quiz answer to the quiz question
            quizQuestion.addToQuizAnswer(quizAnswer)
        }

        quizAnswer.answerText = answerText
        quizAnswer.isCorrectAnswer = isCorrectAnswer
        quizAnswer.isSelected = false

        // save the quiz answer to persistence
        do {
            try managedContext.save()
            return quizAnswer
        } catch let error as NSError {
            if let parentController = parentController {
                showMessage(parentController: parentController, message: "Could not save the quiz answer!")
            }
            print("Could not save quiz answer. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func saveQuizQuestion(questionId: NSManagedObjectID?, quizId: NSManagedObjectID, questionText: String, parentController: UIViewController? = nil) -> QuizQuestion? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        var quizQuestion: QuizQuestion = QuizQuestion()

        if let questionId = questionId {
            // fetch the existing quiz question so we can update it
            if let obj = managedContext.object(with: questionId) as? QuizQuestion {
                quizQuestion = obj
            } else {
                if let parentController = parentController {
                    showMessage(parentController: parentController, message: "Could not find existing quiz question!")
                }
                print("Could not find existing quiz question.")
                return nil
            }
        } else {
            // create a new quiz question
            quizQuestion = QuizQuestion(context: managedContext)
            quizQuestion.createDate = Date()
        }
        quizQuestion.questionText = questionText

        if questionId == nil {
            // it's a new quiz question, so we need to add it to the quiz

            // get the associated quiz for the quiz question
            let quiz = managedContext.object(with: quizId) as! Quiz

            // add the quiz question to the quiz
            quiz.addToQuizQuestion(quizQuestion)
        }

        // save the quiz question to persistence
        do {
            try managedContext.save()
            return quizQuestion
        } catch let error as NSError {
            if let parentController = parentController {
                showMessage(parentController: parentController, message: "Could not save the quiz question!")
            }
            print("Could not save quiz question. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func saveQuizResult(quiz: Quiz, parentController: UIViewController? = nil) -> QuizResult? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let quizResult: QuizResult = QuizResult(context: managedContext)
        quizResult.dateTaken = Date()
        quizResult.quiz = quiz

        // save the quiz result to persistence
        do {
            try managedContext.save()
            return quizResult
        } catch let error as NSError {
            if let parentController = parentController {
                showMessage(parentController: parentController, message: "Could not save the quiz result!")
            }
            print("Could not save the quiz result!. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func saveQuizQuestionResult(
        quizQuestionResultId: NSManagedObjectID?,
        quizResult: QuizResult,
        quizQuestion: QuizQuestion,
        answerText: String,
        isCorrectAnswer: Bool,
        parentController: UIViewController? = nil) -> QuizQuestionResult? {

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        var quizQuestionResult = QuizQuestionResult()

        if let quizQuestionResultId = quizQuestionResultId {
            // fetch the existing quiz question result so we can update it
            if let obj = managedContext.object(with: quizQuestionResultId) as? QuizQuestionResult {
                quizQuestionResult = obj
            } else {
                if let parentController = parentController {
                    showMessage(parentController: parentController, message: "Could not find existing quiz question result!")
                }
                print("Could not find existing quiz question result.")
                return nil
            }
        } else {
            // create a new quiz question result
            quizQuestionResult = QuizQuestionResult(context: managedContext)
            quizQuestionResult.createDate = Date()
            quizQuestion.addToQuizQuestionResult(quizQuestionResult)
            quizResult.addToQuizQuestionResult(quizQuestionResult)
        }

        quizQuestionResult.isCorrectAnswer = isCorrectAnswer
        quizQuestionResult.answerText = answerText

        // save the quiz question result to persistence
        do {
            try managedContext.save()
            return quizQuestionResult
        } catch let error as NSError {
            if let parentController = parentController {
                showMessage(parentController: parentController, message: "Could not save the quiz result!")
            }
            print("Could not save the quiz result!. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func showQuizResults(parentViewController: UIViewController, quizResultId: NSManagedObjectID) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        if let quizResult = managedContext.object(with: quizResultId) as? QuizResult {
            var numCorrect = 0
            var totalQuestions = 0
            for case let quizQuestionResult as QuizQuestionResult in quizResult.quizQuestionResult! {
                numCorrect += quizQuestionResult.isCorrectAnswer ? 1 : 0
                totalQuestions = totalQuestions + 1
            }

            var grade = 0
            if totalQuestions != 0 {
                let g = Double(numCorrect) / Double(totalQuestions)
                grade = Int(round(g * 100))
            }
            
            let quizResultsAlert = UIAlertController(title: "Results",
                                                     message: "You got \(numCorrect) correct out of \(totalQuestions) total questions for a grade of \(grade)",
                                                     preferredStyle: UIAlertControllerStyle.alert)
            
            quizResultsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                parentViewController.performSegue(withIdentifier: "goToMainScreen", sender: parentViewController)
            }))
            
            parentViewController.present(quizResultsAlert, animated: true, completion: { () in
            })
        }
    }

    static func saveQuiz(quizId: NSManagedObjectID?, quizName: String, parentController: UIViewController? = nil) -> Quiz? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        var quiz: Quiz = Quiz()
        if let quizId = quizId {
            // fetch the existing quiz so we can update it
            if let obj = managedContext.object(with: quizId) as? Quiz {
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
            print("Could not save the quiz!. \(error), \(error.userInfo)")
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
        quiz.createDate = Date()

        for i in 0..<5 {
            let quizQuestion = QuizQuestion(context: managedContext)
            quizQuestion.questionText = "This is sample question \(i) for the quiz"
            quizQuestion.createDate = Date()
            quiz.addToQuizQuestion(quizQuestion)
            dummyQuizId = quiz.objectID

            for j in 0..<4 {
                let quizAnswer = QuizAnswer(context: managedContext)
                quizAnswer.answerText = "Answer " + String(j)
                quizAnswer.createDate = Date()
                quizAnswer.isCorrectAnswer = i == j
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
            if quizes.count == 0 {
                return quizes
            }
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

    static func getQuizQuestions(forQuizId quizId: NSManagedObjectID) -> NSMutableSet? {
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

    static func getQuizAnswers(forQuizQuestionId quizQuestionId: NSManagedObjectID) -> [QuizAnswer]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let quizQuestion = managedContext.object(with: quizQuestionId)
        let quizAnswers = quizQuestion.mutableSetValue(forKey: "quizAnswer")

        // sort answers by created date
        var sortedAnswers = quizAnswers.allObjects as! [QuizAnswer]
        sortedAnswers = sortedAnswers.sorted { (a, b) -> Bool in
            if a.createDate != nil && b.createDate != nil {
                return a.createDate! < b.createDate!
            }
            return true
        }

        return sortedAnswers
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
