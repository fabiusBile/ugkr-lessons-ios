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
    var header = UIView()
    var headerBorder = UIView()
    var doneBtn = UIButton(type: .system)
    var onHide: (() -> Void)?
    var onDone: (() -> Void)?
    let h:CGFloat = 1.85

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
        datePickerView.frame = CGRect(x:0.0, y:container.frame.height, width:container.frame.width, height:uiView.frame.height/h)
        datePickerView.backgroundColor = UIColor(red: 210/255, green: 213/255, blue: 219/255, alpha: 1)
        
        picker.datePickerMode = UIDatePickerMode.date
        picker.bounds = CGRect(x:0.0, y:-50.0, width: datePickerView.bounds.width, height: datePickerView.bounds.height-50.0)
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin]

        header.frame = CGRect(x:0, y:0, width: datePickerView.bounds.width, height: 42)
        header.backgroundColor =  UIColor(red: 239/255,	green: 240/255, blue: 241/255, alpha: 1)
        header.autoresizingMask = [.flexibleWidth]
        
        headerBorder.frame = CGRect(x:0, y:0, width: datePickerView.bounds.width, height: 1)
        headerBorder.backgroundColor = UIColor(red: 194/255, green: 195/255, blue:	198/255, alpha: 1)
        headerBorder.autoresizingMask = [.flexibleWidth]
        
        doneBtn.frame = CGRect(x:datePickerView.bounds.width-100, y:0.0, width:100, height:42)
        doneBtn.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        doneBtn.setTitle("Готово", for: .normal)
        doneBtn.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 16)
        doneBtn.addTarget(self, action: #selector(self.onDonePressed(_: )), for: UIControlEvents.touchUpInside)
        
        container.addSubview(datePickerView)
        datePickerView.addSubview(header)
        header.addSubview(doneBtn)
        header.addSubview(headerBorder)
        datePickerView.addSubview(picker)
        uiView.addSubview(container)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap (_:)))
        container.addGestureRecognizer(tapRecognizer)
        
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut], animations: {
            self.datePickerView.frame = CGRect(x:0.0, y:self.container.frame.height/self.h, width:self.container.frame.width, height:self.container.frame.height/self.h)
        })
        
    }
    func hide(){
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseInOut], animations: {
            self.datePickerView.frame = CGRect(x:0.0, y:self.container.frame.height, width:self.container.frame.width, height:self.container.frame.height/self.h)
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
