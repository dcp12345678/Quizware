//
//  ViewController.swift
//  Testware
//
//  Created by TechReviews on 1/8/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import UIKit
import CoreData

enum CellExpandedState {
    case Expanded
    case Collapsed
}

class QuizTableViewCell : UITableViewCell {
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var lblNumberOfQuestions: UILabel!
    @IBOutlet weak var lblSuccessRate: UILabel!
    @IBOutlet weak var detailStackView: UIStackView!
    var isExpanded: Bool = false
    
    @IBOutlet weak var btnViewHistory: UIButton!    
    @IBOutlet weak var btnTakeTest: UIButton!
}

class MainViewController: UITableViewController {
    
    var expandedQuizIds = Set<NSManagedObjectID>()
    let mainViewCellIdentifier = "MainView"
    var quizes: [NSManagedObject]? = nil

    @IBOutlet var quizesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Helper.deleteQuizData()
        Helper.loadQuizData(quizNumber: 1)
        Helper.loadQuizData(quizNumber: 2)
        Helper.loadQuizData(quizNumber: 3)
        
        quizesTableView.separatorColor = UIColor.white
        quizesTableView.separatorInset = .zero
        quizesTableView.layoutMargins = .zero
        
        // this step is done to remove the empty cells from end of table view
        quizesTableView.tableFooterView = UIView()
        
        quizesTableView.rowHeight = UITableViewAutomaticDimension
        quizesTableView.estimatedRowHeight = 120

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
        pinBackground(backgroundView, to: cell.rootStackView)
        
        if !cell.isExpanded {
            cell.detailStackView.isHidden = true
        }
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return quizes == nil ? 0 : quizes!.count
    }

    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
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
                
                // store the row index in the buttons' tags so we know what quiz the button's
                // are associated with
                cell.btnTakeTest.tag = indexPath.row
                cell.btnViewHistory.tag = indexPath.row
                
                UIView.animate(withDuration: 0.2) {
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
    
}

