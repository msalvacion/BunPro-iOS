//
//  GrammarLevelTableViewController.swift
//  BunPuro
//
//  Created by Andreas Braun on 07.11.17.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import UIKit
import BunPuroKit
import CoreData

class GrammarLevelTableViewController: CoreDataFetchedResultsTableViewController<Lesson>, SegueHandler {

    enum SegueIdentifier: String {
        case showGrammarLevel
    }
    
    var level: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d", #keyPath(Lesson.jlpt.level), level)
        
        let sort = NSSortDescriptor(key: #keyPath(Lesson.order), ascending: true)
        request.sortDescriptors = [sort]
                
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate.coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)

        let lesson = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = String.localizedStringWithFormat(NSLocalizedString("level.number", comment: "Level in a JLPT"), indexPath.row + 1)
        cell.detailTextLabel?.text = "\(lesson.grammar?.count ?? 0)"

        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showGrammarLevel:
            guard let indexPath = tableView.indexPathForSelectedRow else { fatalError("An index path is needed.") }
            guard let cell = tableView.cellForRow(at: indexPath) else { fatalError("A cell is needed.") }
            
            let destination = segue.destination.content as? GrammarPointsTableViewController
            destination?.title = cell.textLabel?.text
            destination?.lesson = fetchedResultsController.object(at: indexPath)
        }
    }
}