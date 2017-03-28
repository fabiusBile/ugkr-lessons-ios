//
//  ScheduleList.swift
//  lessons
//
//  Created by Fabius Bile on 09.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit

class ScheduleList: UITableViewController {
    var lessons:Array<Dictionary<String,String>> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lessons.count
    }

//    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath) as! LessonCell
//        let height = cell.lesson.contentSize.height
//        
//        return height
//    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath) as! LessonCell
        let n = indexPath.item
        cell.num.text = lessons[n]["num"]
        cell.lesson.text = lessons[n]["lesson"]
        return cell
    }

}
