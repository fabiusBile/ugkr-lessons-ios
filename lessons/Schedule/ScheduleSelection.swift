//
//  ScheduleSelection.swift
//  lessons
//
//  Created by Fabius Bile on 05.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit
import CoreData
class ScheduleSelection: UITableViewController {
    
    let activityIndicator = ActivityIndicator.shared
    let datePicker = DatePicker.shared
    var lessons:Array<Dictionary<String,String>> = []
    var rootView = UIView()

    var selectedGroupCode = "";
    var selectedGroupIsGroup = false;

    @IBOutlet weak var selectedGroupName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView = UIApplication.shared.keyWindow!.rootViewController!.view!
        setGroupCell()
    }

    func setGroupCell(){
        selectedGroupName.text = UserDefaults.standard.string(forKey: "selectedGroupName") ?? "Выберите группу"
        selectedGroupCode = UserDefaults.standard.string(forKey: "selectedGroupCode") ?? ""
        selectedGroupIsGroup = UserDefaults.standard.bool(forKey: "selectedGroupIsGroup")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1){
            switch indexPath.item {
            case 0:
                let date = Date()
                showSchedule(date: date)
            case 1:
                let date = Date(timeIntervalSinceNow: 60*60*24)
                showSchedule(date: date)
            case 2:
                datePicker.showDatePicker(uiView: rootView, onHide: deselectRow, onDone: datePickerDateSelected)
            default:
                break
            }
        } else {
            OperationQueue.main.addOperation {
                self.performSegue(withIdentifier: "selectGroup", sender: nil)
            }
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
    
    func showSchedule(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let act = selectedGroupIsGroup ? "1" : "4"
        let savedCode = UserDefaults.standard.string(forKey: "savedGroupCode")
        let savedDate = UserDefaults.standard.string(forKey: "savedDate")
        let savedScheduleString = UserDefaults.standard.string(forKey: "savedSchedule");

        if (dateString == savedDate && selectedGroupCode == savedCode && savedScheduleString != "")
        {
            
            let data = savedScheduleString!.data(using: String.Encoding.utf8)
            do {
                self.lessons = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! Array<Dictionary<String,String>>
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "showSchedule", sender: nil)
                }
            } catch let error as NSError {
                self.activityIndicator.hide()
                self.showAlert(title: "Произошла ошибка")
                print(error)
            }
        } else {
            let url = URL(string: "https://ugkr-server.000webhostapp.com/?action=getSchedule&act=\(act)&code=\(selectedGroupCode)&date=\(dateString)")
            
            let task =   URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                if (dataString != nil){
                    if ((dataString!) != "NO_SCHEDULE"){
                        do {
                            self.lessons = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! Array<Dictionary<String,String>>
                            if (dateString == dateFormatter.string(from: Date())){
                                UserDefaults.standard.set(self.selectedGroupCode, forKey:"savedGroupCode")
                                UserDefaults.standard.set(dataString, forKey:"savedSchedule")
                                UserDefaults.standard.set(dateString, forKey:"savedDate")
                            }
                            OperationQueue.main.addOperation {
                                self.activityIndicator.hide()
                                self.performSegue(withIdentifier: "showSchedule", sender: nil)
                            }
                        } catch let error as NSError {
                            OperationQueue.main.addOperation {
                                self.activityIndicator.hide()
                                self.showAlert(title: "Произошла ошибка")
                                print(error)
                            }
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            self.activityIndicator.hide()
                            self.showAlert(title: "Расписание отсутствует")
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        self.activityIndicator.hide()
                        self.showAlert(title: "Произошла ошибка")
                    }
                }
            })
            
            

            func stopTask(){
                task.cancel()
                deselectRow()
            }
            
            activityIndicator.showActivityIndicator(uiView: rootView, onHide: stopTask)
            
            task.resume()
        }
    }
    func datePickerDateSelected(){
        showSchedule(date: datePicker.date)
    }
    func deselectRow(){
        let selectedRow = self.tableView.indexPathForSelectedRow
        if (selectedRow != nil){
            self.tableView.deselectRow(at: selectedRow!, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSchedule"{
            let scheduleList = segue.destination as? ScheduleList
              scheduleList?.lessons = self.lessons
        } else if segue.identifier == "selectGroup" {
            let groupTable = segue.destination as? GroupsTable
            groupTable!.backView = self
        }
    }
}
