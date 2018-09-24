//
//  ViewController.swift
//  Testware
//
//  Created by TechReviews on 1/8/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit
import CoreData

class QuizTableViewCell: UITableViewCell {
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var lblNumberOfQuestions: UILabel!
    @IBOutlet weak var lblSuccessRate: UILabel!
    @IBOutlet weak var detailStackView: UIStackView!
    var isExpanded: Bool = false

    @IBOutlet weak var btnViewHistory: UIButton!
    @IBOutlet weak var btnTakeTest: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
}

class MainViewController: UITableViewController {

    var expandedQuizIds = Set<NSManagedObjectID>()
    let mainViewCellIdentifier = "MainView"
    var quizes: [NSManagedObject]? = nil
    var selectedQuiz: NSManagedObject? = nil

    @IBOutlet var quizesTableView: UITableView!

    
    @IBAction func btnEditWasTapped(_ sender: Any) {
        selectedQuiz = quizes?[(sender as! UIButton).tag]
        performSegue(withIdentifier: "editQuiz", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        quizesTableView.separatorColor = UIColor.white
        quizesTableView.separatorInset = .zero
        quizesTableView.layoutMargins = .zero

        // this step is done to remove the empty cells from end of table view
        quizesTableView.tableFooterView = UIView()

        quizesTableView.rowHeight = UITableViewAutomaticDimension
        quizesTableView.estimatedRowHeight = 120

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addOnPress))
    }

    @objc func addOnPress() {
        //Helper.showMessage(parentController: self, message: "add button tapped!")
        performSegue(withIdentifier: "editQuiz", sender: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // need to fetch quizes
        quizes = Helper.fetchQuizData()

        self.quizesTableView.reloadData()

        quizesTableView.beginUpdates()
        quizesTableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainViewCellIdentifier, for: indexPath)
        as! QuizTableViewCell
        let rowData = quizes?[indexPath.row]
        cell.lblTestName.text = rowData?.value(forKey: "name") as? String
        if let quizQuestions = rowData?.mutableSetValue(forKey: "quizQuestion") {
            cell.lblNumberOfQuestions.text = String(quizQuestions.count)
        }
        cell.contentView.tag = indexPath.row

        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)

        let backgroundView: UIView = {
            let view = UIView()
            let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            view.backgroundColor = color
            view.layer.cornerRadius = 10.0
            return view
        }()
        Helper.pinBackground(backgroundView, to: cell.rootStackView)

        if !cell.isExpanded {
            cell.detailStackView.isHidden = true
        }

        // ----------------------
        // setup button icons
        // ----------------------

        cell.btnTakeTest.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        cell.btnTakeTest.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)

        cell.btnViewHistory.setTitle(String.fontAwesomeIcon(name: .barChart), for: .normal)
        cell.btnViewHistory.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)

        cell.btnEdit.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
        cell.btnEdit.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        cell.btnEdit.tag = indexPath.row

        cell.btnDelete.setTitle(String.fontAwesomeIcon(name: .trash), for: .normal)
        cell.btnDelete.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)

        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete logic goes here
        }

        return [delete]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizes == nil ? 0 : quizes!.count
    }

    @objc func cellViewTapped(_ sender: UITapGestureRecognizer) {
        let indexPath = NSIndexPath(row: (sender.view?.tag)!, section: 0) as IndexPath
        if let cell = quizesTableView.cellForRow(at: indexPath as IndexPath) as? QuizTableViewCell {
            // if cell is expanded, then collapse it, otherwise, expand it
            expandOrCollapseCell(at: indexPath, targetState: cell.isExpanded ? CellExpandedState.Collapsed : CellExpandedState.Expanded)
            quizesTableView.beginUpdates()
            quizesTableView.endUpdates()

            // scroll to the row the user tapped
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }

    private func expandOrCollapseCell(at indexPath: IndexPath, targetState: CellExpandedState) {
        if let cell = quizesTableView.cellForRow(at: indexPath as IndexPath) as? QuizTableViewCell {
            let rowData = quizes?[indexPath.row]
            let id = rowData!.objectID

            if targetState == .Expanded {

                //
                // we need to expand the cell's detail view
                //

                cell.isExpanded = true
                expandedQuizIds.insert(id)

                //let lineItems = try OrdersApi.getOrderLineItems(forOrderId: id)

                // store the row index in the buttons' tags so we know what quiz the buttons
                // are associated with
                cell.btnTakeTest.tag = indexPath.row
                cell.btnViewHistory.tag = indexPath.row
                cell.btnDelete.tag = indexPath.row
                cell.btnEdit.tag = indexPath.row

                UIView.animate(withDuration: 0.1) {
                    cell.detailStackView.isHidden = false;
                }
                
            } else {
                // collapse the cell's detail view
                cell.detailStackView.isHidden = true;
                expandedQuizIds.remove(id)
                cell.isExpanded = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editQuiz" {
            // store the quiz in the target controller
            if case let quiz as Quiz = selectedQuiz {
                (segue.destination as! EditQuizViewController).quiz = quiz
            }
        }
    }

}

