//
//  DatePicker.swift
//  lessons
//
//  Created by Fabius Bile on 28.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import UIKit

class DatePicker{
    
    
    var picker = UIDatePicker()
    var datePickerView = UIView()
    var container = UIView()
    var doneBtn = UIButton(type: .system)
    var onHide: (() -> Void)?
    var onDone: (() -> Void)?

    var date: Date{
        get {return picker.date}
    }
    
    static let shared = DatePicker()
    
    private init(){}

    func showDatePicker(uiView: UIView, onHide: (() -> Void)? = nil, onDone: (() -> Void)? = nil){
        self.onHide = onHide
        self.onDone = onDone
        container.bounds = uiView.bounds
        container.center = uiView.center
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        datePickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin]
        datePickerView.frame = CGRect(x:0.0, y:container.frame.height, width:container.frame.width, height:uiView.frame.height/2)
        datePickerView.backgroundColor = .white
        
        picker.datePickerMode = UIDatePickerMode.date
        picker.bounds = CGRect(x:0.0, y:-50.0, width: datePickerView.bounds.width, height: datePickerView.bounds.height-50.0)
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin]

        doneBtn.frame = CGRect(x:datePickerView.bounds.width-100, y:0.0, width:100, height:50)
        doneBtn.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        doneBtn.setTitle("Готово", for: .normal)
        doneBtn.addTarget(self, action: #selector(self.onDonePressed(_: )), for: UIControlEvents.touchUpInside)
        
        container.addSubview(datePickerView)
        datePickerView.addSubview(doneBtn)
        datePickerView.addSubview(picker)
        uiView.addSubview(container)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap (_:)))
        container.addGestureRecognizer(tapRecognizer)
        
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut], animations: {
            self.datePickerView.frame = CGRect(x:0.0, y:self.container.frame.height/2, width:self.container.frame.width, height:self.container.frame.height/2)
        })
        
    }
    func hide(){
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut], animations: {
            self.datePickerView.frame = CGRect(x:0.0, y:self.container.frame.height, width:self.container.frame.width, height:self.container.frame.height/2)
        },completion: {(finished : Bool) in
            if (finished){
                self.container.removeFromSuperview()
                if (self.onHide != nil){
                    self.onHide!()
                }
            }
        })
    }
    @objc func onTap(_ sender:UITapGestureRecognizer){
        hide()
    }
    @objc func onDonePressed(_ sender: UIButton){
        if (onDone != nil){
            onDone!()
        }
        hide()
    }

}
