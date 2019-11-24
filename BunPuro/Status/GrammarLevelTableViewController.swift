//
//  Created by Andreas Braun on 07.11.17.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import BunProKit
import CoreData
import Protocols
import UIKit

final class GrammarLevelTableViewController: CoreDataFetchedResultsTableViewController<Grammar>, SegueHandler {
    enum SegueIdentifier: String {
        case showGrammar
    }

    var level: Int = 5

    private var searchBarButtonItem: UIBarButtonItem!
    private var activityIndicatorView: UIActivityIndicatorView?

    private var statusObserver: StatusObserverProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        statusObserver = StatusObserver.newObserver()

        if #available(iOS 13.0, *) {
            activityIndicatorView = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicatorView = UIActivityIndicatorView(style: .gray)
        }
        activityIndicatorView?.hidesWhenStopped = true

        searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [/*searchBarButtonItem, */UIBarButtonItem(customView: activityIndicatorView!)]

        statusObserver?.willBeginUpdating = { [weak self] in
            self?.activityIndicatorView?.startAnimating()
        }

        statusObserver?.didEndUpdating = { [weak self] in
            self?.activityIndicatorView?.stopAnimating()
            self?.tableView.reloadData()
        }

        let request: NSFetchRequest<Grammar> = Grammar.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Grammar.level), "JLPT\(level)")

        let levelSort = NSSortDescriptor(key: #keyPath(Grammar.level), ascending: false)
        let orderSort = NSSortDescriptor(key: #keyPath(Grammar.lessonIdentifier), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let identifierSort = NSSortDescriptor(key: #keyPath(Grammar.identifier), ascending: true)

        request.sortDescriptors = [levelSort, orderSort, identifierSort]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: AppDelegate.database.viewContext,
            sectionNameKeyPath: #keyPath(Grammar.lessonIdentifier),
            cacheName: nil
        )
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as GrammarTeaserCell
        let grammar = fetchedResultsController.object(at: indexPath)
        let hasReview = grammar.review?.complete == true

        cell.japaneseLabel?.text = grammar.title
        cell.meaningLabel?.text = grammar.meaning
        cell.isComplete = hasReview

        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard AppDelegate.isContentAccessable else { return nil }

        let point = fetchedResultsController.object(at: indexPath)
        let review = point.review
        let hasReview = review?.complete ?? false

        var actions = [UIContextualAction]()

        if hasReview {
            let removeReviewAction = UIContextualAction(style: .normal, title: L10n.Review.Edit.Remove.short) { _, _, completion in
                AppDelegate.modifyReview(.remove(review!.identifier))
                completion(true)
            }

            removeReviewAction.backgroundColor = .red

            let resetReviewAction = UIContextualAction(style: .normal, title: L10n.Review.Edit.Reset.short) { _, _, completion in
                AppDelegate.modifyReview(.reset(review!.identifier))
                completion(true)
            }

            resetReviewAction.backgroundColor = .purple

            actions.append(removeReviewAction)
            actions.append(resetReviewAction)
        } else {
            let addToReviewAction = UIContextualAction(style: UIContextualAction.Style.normal, title: L10n.Review.Edit.Add.short) { _, _, completion in
                AppDelegate.modifyReview(.add(point.identifier))
                completion(true)
            }

            actions.append(addToReviewAction)
        }

        let configuration = UISwipeActionsConfiguration(actions: actions)

        return configuration
    }

    private func progress(count: Int, max: Int) -> Float {
        guard max > 0 else { return 0 }
        return Float(count) / Float(max)
    }

    private func correctLevel(_ level: Int) -> Int {
        let mod = level % 10
        return mod == 0 ? 10 : mod
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let name = fetchedResultsController?.sections?[section].name, let level = Int(name) else { return nil }
        let cell = tableView.dequeueReusableCell() as JLPTProgressTableViewCell

        let grammarPoints = fetchedResultsController.fetchedObjects?.filter { $0.lessonIdentifier == name } ?? []
        let grammarCount = grammarPoints.count
        let finishedGrammarCount = grammarPoints.filter { $0.review?.complete == true }.count

        cell.title = L10n.Level.number(correctLevel(level))
        cell.subtitle = "\(finishedGrammarCount) / \(grammarCount)"
        cell.setProgress(progress(count: finishedGrammarCount, max: grammarCount), animated: false)

        return cell.contentView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sections?.compactMap { section in
            guard let level = Int(section.name) else { return nil }
            return "\(correctLevel(level))"
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showGrammar:
            guard let cell = sender as? UITableViewCell else { fatalError("expected showGrammer segue to be of type `UITableViewCell`") }
            guard let indexPath = tableView.indexPath(for: cell) else { fatalError("expected showGrammer cell to be part of a table view") }

            let controller = segue.destination.content as? GrammarTableViewController
            controller?.grammar = fetchedResultsController.object(at: indexPath)
        }
    }
}
