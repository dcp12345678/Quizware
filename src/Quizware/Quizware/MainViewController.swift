//
//  ViewController.swift
//  Testware
//
//  Created by TechReviews on 1/8/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit
import CoreData

class TestTableViewCell : UITableViewCell {
    @IBOutlet weak var rootStackView: UIStackView!
}

class MainViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        deleteDummyData()
        loadDummyData(quizNumber: 1)
        loadDummyData(quizNumber: 2)
        loadDummyData(quizNumber: 3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDummyData(quizNumber: Int) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Quiz",
                                                in: managedContext)!
        let quiz = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        
        quiz.setValue("sample test " + String(quizNumber), forKeyPath: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchDummyData() -> [NSManagedObject]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Quiz")
        
        do {
            let quizes = try managedContext.fetch(fetchRequest)
            print("\(quizes)")
            return quizes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func deleteDummyData() {
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
    
    @IBAction func onTestBtnPressed(_ sender: Any) {
    }
}

