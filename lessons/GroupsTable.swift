//
//  GroupsTable.swift
//  lessons
//
//  Created by Fabius Bile on 16.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit
import CoreData
protocol FavChanged {
    func favChanged(_ model: GroupCell, isFav: Bool)
}
class GroupsTable: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,FavChanged  {
    let onlyFav = NSPredicate(format: "favourite == YES")
    let onlyGroups = NSPredicate(format: "isGroup == YES")
    let onlyTeachers = NSPredicate(format: "isGroup == NO")
    let refreshControl = UIRefreshControl()
    var backView = ScheduleSelection()
    
    func favChanged(_ model: GroupCell, isFav: Bool) {
        let indexPath = self.tableView.indexPath(for: model)
        let group = fetchedResultsController.object(at: indexPath!)
        group.favourite = isFav
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    func showAlert(title: String, text: String? = nil){
        let alert: UIAlertView = UIAlertView()
        
        alert.delegate = self
        
        alert.title = title
        if (text != nil){
            alert.message = text
        }
        alert.addButton(withTitle: "Закрыть")
        
        alert.show()
    }
    
    func updateGroups() {
        let url = URL(string: "https://ugkr-server.000webhostapp.com/?action=getLinks")
        
        let task =   URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            if (dataString != nil){
                    do {
                        let groups = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! Dictionary<String,[Dictionary<String,String>]>
                        var isGroup = true
                        
                        for type in ["groups","teachers"]{
                            for group in groups[type]!{
                                let isInBase = NSFetchRequest<Group>(entityName: "Group")
                                let predicate = NSPredicate(format: "code=%@", group["code"]!)
                                isInBase.predicate = predicate
                                do {
                                   let results = try self.context.fetch(isInBase)
                                    if (results.count > 0){
                                        results[0].name = group["name"]
                                        
                                    } else {
                                        let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: self.context) as! Group
                                        newGroup.name = group["name"]
                                        newGroup.code = group["code"]
                                        newGroup.isGroup = isGroup
                                        newGroup.favourite = false
                                    }
                                   try  self.context.save()
                                } catch {
                                    fatalError("Failure to save context: \(error)")
                                }
                            }
                            isGroup = !isGroup
                        }
                        self.tableView.reloadData()
                        OperationQueue.main.addOperation {
                            self.refreshControl.endRefreshing()
                        }
                    } catch let error as NSError {
                        OperationQueue.main.addOperation {
                            self.showAlert(title: "Произошла ошибка")
                            self.refreshControl.endRefreshing()
                            print(error)
                        }
                    }
            } else {
                OperationQueue.main.addOperation {
                    self.showAlert(title: "Произошла ошибка")
                    self.refreshControl.endRefreshing()

                }
            }
        })
        
        task.resume()
    }


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchedResultsController.fetchRequest.predicate = onlyGroups
        case 1:
            fetchedResultsController.fetchRequest.predicate = onlyTeachers
        case 2:
            fetchedResultsController.fetchRequest.predicate = onlyFav
        default:
            break
        }
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        do{
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failure to perform fetch: \(error)")
        }
    }
    @IBOutlet var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<Group>!
    open var context: NSManagedObjectContext!
    var n=0;
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case NSFetchedResultsChangeType.delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex)  as IndexSet, with: .fade)
        default: break
            
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let tableView = self.tableView!
        switch type {
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case NSFetchedResultsChangeType.delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case NSFetchedResultsChangeType.update:
            let cell = tableView.cellForRow(at: indexPath!)
            if (cell != nil){
                self.configureCell(cell!, at: indexPath!)

            }
        case NSFetchedResultsChangeType.move:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        }
        
    }
    
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let group: Group? = self.fetchedResultsController.object(at: indexPath)
        let groupCell = cell as! GroupCell
        groupCell.groupName.text = group?.name
        groupCell.favBtn.isSelected = (group?.favourite)!
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func refresh(_ sender: UIRefreshControl) {
       // seedGroup()
        updateGroups()
    }
    func configureFetchedResultsController(){
        let groupsFetchRequest = NSFetchRequest<Group>(entityName: "Group")
        let favSort = NSSortDescriptor(key: "favourite", ascending: false)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        groupsFetchRequest.sortDescriptors = [favSort,nameSort]
        self.fetchedResultsController  = NSFetchedResultsController<Group>(
            fetchRequest: groupsFetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.fetchedResultsController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        context = DataController().managedObjectContext
        configureFetchedResultsController()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        let selectedSegmentedIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
        segmentedControl.selectedSegmentIndex = selectedSegmentedIndex
        segmentedControlChanged(segmentedControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            if currentSection.numberOfObjects == 0 && segmentedControl.selectedSegmentIndex != 2{
                refreshControl.beginRefreshing()
                refresh(refreshControl)
            }
            return currentSection.numberOfObjects
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = fetchedResultsController.object(at: indexPath)
        UserDefaults.standard.set(group.name, forKey:"selectedGroupName")
        UserDefaults.standard.set(group.code, forKey:"selectedGroupCode")
        UserDefaults.standard.set(group.isGroup, forKey:"selectedGroupIsGroup")
        backView.setGroupCell()
        navigationController?.popViewController(animated: true)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "group")! as! GroupCell
        let group = fetchedResultsController.object(at: indexPath)
        cell.groupName.text = group.name
        cell.favBtn.isSelected = group.favourite
        cell.delegate = self
        return cell
    }

}
