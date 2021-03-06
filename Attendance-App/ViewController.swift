//
//  ViewController.swift
//  Attendance-App
//
//  Created by Bill Gan on 2015-08-25.
//  Copyright (c) 2015 InsightSearch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var loc_num: Int = 1                            //number of set of locations
    //dictionaries of name to label/text field/button
    var name_to_label_1 = [String: UILabel]()       //labels that belong to interface_1
    var name_to_label_2 = [String: UILabel]()       //labels that belong to interface_2
    var name_to_tf = [String: UITextField]()
    var name_to_button = [String: UIButton]()
    var personInfo: PersonData?
    
    // names and sizes corresponding to the names
    let data_list = ["Company Name", "Employee Name", "Date"]
    let size_list = [130, 130, 40]
    
    let data_list2 = ["Location", "Start Time", "End Time"]
    let size_list2 = [80, 90, 80]
    
    //database variables
    var database: FMDatabase!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initDatabase()
        self.draw_Interface_1()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func draw_Interface_1(){
        // add labels and text fields for company name, employee name, and date
        for i in 0...2 {
            var label = createLabel(self.data_list[i], px: 30, py: 50 + i * 50, width : self.size_list[i], height: 30)
            self.name_to_label_1[self.data_list[i]] = label
            self.view.addSubview(label)
            var tf = createTextField(50 + self.size_list[i], py: 50 + i * 50, width: 150, height: 30)
            self.name_to_tf[self.data_list[i]] = tf
            self.view.addSubview(tf)
        }
        
        // add labels and text fields for location, start time and end time
        for i in 0...2 {
            var label = createLabel(self.data_list2[i], px: 30, py: 250 + i * 50, width : self.size_list2[i], height: 30)
            self.name_to_label_1[self.data_list2[i]] = label
            self.view.addSubview(label)
            var tf = createTextField(50 + self.size_list2[i], py: 250 + i * 50, width: 150, height: 30)
            self.name_to_tf[self.data_list2[i]] = tf
            self.view.addSubview(tf)
            
        }
        
        // create and modify "add location" button
        var button = createButton("Add Location", px: 50, py: 200, width: 100, height: 30)
        button.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        button.titleLabel!.textAlignment = .Center;
        button.addTarget(self, action: "hitAddLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        self.name_to_button["Add Location"] = button
        self.view.addSubview(button)
        
        // create and modify "enter button"
        var button2 = createButton("Enter", px: 200, py: 200, width: 100, height: 30)
        self.name_to_button["Enter"] = button2
        button2.addTarget(self, action: "hitEnter:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button2)
    }
    
    // return an UILabel, UITextField, UIButton given context
    func createLabel(t:String, px:Int, py: Int, width: Int, height:Int) -> UILabel{
        var rect = CGRectMake(CGFloat(px), CGFloat(py), CGFloat(width), CGFloat(height))
        var label = UILabel(frame: rect)
        label.text = t
        return label
    }
    
    func createTextField(px: Int, py: Int, width: Int, height: Int) -> UITextField{
        var rect = CGRectMake(CGFloat(px), CGFloat(py), CGFloat(width), CGFloat(height))
        var tf = UITextField(frame: rect)
        tf.backgroundColor = UIColor.grayColor()
        tf.delegate = self;
        return tf
    }
    
    func createButton(t:String, px:Int, py: Int, width: Int, height:Int) -> UIButton{
        var rect = CGRectMake(CGFloat(px), CGFloat(py), CGFloat(width), CGFloat(height))
        var button = UIButton(frame: rect)
        button.setTitle(t, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        return button
    }
    
    func addSet(num: Int){
        // add a set of location, start time and end time
        for i in 0...2 {
            var t = self.data_list2[i] + " " + String(num)
            var label = createLabel(t, px: 30, py: 250 + i * 50 + (num - 1) * 150, width: size_list2[i] + 30, height: 30)
            self.name_to_label_1[t] = label
            self.view.addSubview(label)
            
            var tf = createTextField(30 + size_list2[i] + 30, py: 250 + i * 50 + (num - 1) * 150, width: 150, height: 30)
            self.name_to_tf[t] = tf
            self.view.addSubview(tf)
        }
    }
    
    func hitAddLocation(sender: UIButton){
        // action taken when user presses addlocation button
        // limited to at most 3 locations each day
        if self.loc_num < 3{
            self.loc_num += 1
            self.addSet(self.loc_num)
        }
    }
    
    func hitEnter(sender: UIButton){
        // action taken when user presses enter button
        
        self.personInfo = PersonData(cn: self.name_to_tf[data_list[0]]!.text, en: self.name_to_tf[data_list[1]]!.text, date: self.name_to_tf[data_list[2]]!.text, location_list: get_location_list(), st_list: get_st_list(), et_list: get_et_list())
        self.clear_Interface_1()
        self.draw_Interface_2()
    }
    
    func clear_Interface_1(){
        // remove everything that belongs to interface_1
        for (name, label) in name_to_label_1{
            name_to_label_1[name]?.removeFromSuperview()
        }
        for (name, tf) in name_to_tf{
            name_to_tf[name]?.removeFromSuperview()
        }
        name_to_button["Add Location"]?.removeFromSuperview()
        name_to_button["Enter"]?.removeFromSuperview()
    }
    
    // functions for interface_2
    func draw_Interface_2(){
        
        // draw the result labels based on the input from interface_!
        var sign : UILabel
        sign = createSign("Result", px: 150, py: 50, width: 150, height: 50, size: 30, center: false)
        self.name_to_label_2["Result"] = sign
        self.view.addSubview(sign)

        sign = createSign(self.personInfo!.employee_name, px: 100, py: 100, width: 150, height: 30, size: 25, center: true)
        self.name_to_label_2[self.data_list[1]] = sign
        self.view.addSubview(sign)
        
        sign = createSign(self.personInfo!.company_name, px: 100, py: 130, width: 150, height: 30, size: 25, center: true)
        self.name_to_label_2[self.data_list[0]] = sign
        self.view.addSubview(sign)
        
        sign = createSign("Date: " + self.personInfo!.date, px: 50, py: 180, width: 200, height: 30, size: 20, center: false)
        self.name_to_label_2[self.data_list[2]] = sign
        self.view.addSubview(sign)
        
        // draw all the set of locations
        for i in 1...self.loc_num{
            var t = "Location " + String(i) + ": " + self.personInfo!.location_list[i - 1]
            var t2 = "Hour: " + self.personInfo!.time_list[i - 1]
            
            sign = createSign(t, px: 50, py: 250 + (i - 1) * 80, width: 200, height: 30, size: 20, center: false)
            self.name_to_label_2["Location " + String(i)] = sign
            self.view.addSubview(sign)
            
            sign = createSign(t2, px: 50, py: 290 + (i - 1) * 80, width: 200, height: 30, size: 20, center: false )
            self.name_to_label_2["Hour " + String(i)] = sign
            self.view.addSubview(sign)
            
        }
        //remove confirm and go back button
        
        var button = createButton("Confirm", px: 50, py: 500, width: 100, height: 30)
        name_to_button["Confirm"] = button
        self.view.addSubview(button)
        button.addTarget(self, action: "hitConfirm:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var button2 = createButton("Go Back", px: 200, py: 500, width: 100, height: 30)
        name_to_button["Go Back"] = button2
        self.view.addSubview(button2)
        button2.addTarget(self, action: "hitGoBack:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func createSign(t: String, px: Int, py: Int, width: Int, height: Int, size: Int, center: Bool) -> UILabel{
        var rect = CGRectMake(CGFloat(px), CGFloat(py), CGFloat(width), CGFloat(height))
        var sign = UILabel(frame: rect)
        sign.text = t
        sign.font = sign.font.fontWithSize(CGFloat(size))
        if center{
            sign.textAlignment = .Center;
        }
        return sign
    }
    
    //the following 3 methods return a list of location/start time/ end time based on the user's input
    
    func get_location_list() -> [String]{
        //this
        var result = [String]()
        for i in 1...self.loc_num{
            if i == 1{
                // it's location, not location 1
                result.append(self.name_to_tf[data_list2[0]]!.text)
            }
            else{
                result.append(self.name_to_tf[data_list2[0] + " " + String(i)]!.text)
            }
        }
        return result
    }
    
    func get_st_list() -> [String]{
        //this
        var result = [String]()
        for i in 1...self.loc_num{
            if i == 1{
                result.append(self.name_to_tf[data_list2[1]]!.text)
            }
            else{
                result.append(self.name_to_tf[data_list2[1] + " " + String(i)]!.text)
            }
        }
        return result
    }
    
    func get_et_list() -> [String]{
        //this
        var result = [String]()
        for i in 1...self.loc_num{
            if i == 1{
                result.append(self.name_to_tf[data_list2[2]]!.text)
            }
            else{
                result.append(self.name_to_tf[data_list2[2] + " " + String(i)]!.text)
            }
        }
        return result
    }
    
    func hitConfirm(sender: UIButton){
        // action taken when user presses confirm button
        self.clear_Interface_2()
        self.addData()
        self.resetData()
        self.draw_Interface_1()
        
    }
    
    func hitGoBack(sender: UIButton){
        // action taken when user presses go back button
        self.clear_Interface_2()
        self.resetData()
        self.draw_Interface_1()
    }
    
    //reinitalize all the variables
    func resetData(){
        self.loc_num = 1
        self.name_to_label_1 = [String: UILabel]()
        self.name_to_label_2 = [String: UILabel]()
        self.name_to_tf = [String: UITextField]()
        self.name_to_button = [String: UIButton]()
        self.personInfo = nil
    }
    
    // add personInfo into database
    func addData(){
        if self.database.open(){
            var locations = [String]()
            var hours = [String]()
            for i in 0...2{
                if (i + 1) <= self.loc_num{
                    locations.append(self.personInfo!.location_list[i])
                    hours.append(self.personInfo!.time_list[i])
                }
                else{
                    locations.append("")
                    hours.append ("")
                }
            }
            let insertSQL = "INSERT INTO WORKERS (company_name, employee_name, date, location_1, hour_1, location_2, hour_2, location_3, hour_3) VALUES ('\(self.personInfo!.company_name)', '\(self.personInfo!.employee_name)', '\(self.personInfo!.date)', '\(locations[0])', '\(hours[0])', '\(locations[1])', '\(hours[1])', '\(locations[2])', '\(hours[2])')"
            let result = self.database.executeUpdate(insertSQL,
                withArgumentsInArray: nil)
            if !result{
                println("Failed Action")
            }
            else{
                println("Contact added")
            }
        }
        else{
            println("Cannot Find Database")
        }
        
    }
    // search function
    func searchName(name: String){
        if self.database.open(){
            let querySQL = "SELECT employee_name, company_name, date FROM WORKERS WHERE employee_name = '\(name)'"
            //let querySQL = "SELECT employee_name, company_name, date, location_1, hour_1 FROM WORKERS"
            let results:FMResultSet = self.database.executeQuery(querySQL,
                withArgumentsInArray: nil)
            while results.next() == true{
                
                println(results.stringForColumn("employee_name"))
                println(results.stringForColumn("company_name"))
                println(results.stringForColumn("date"))


            }
        }
        self.database.close()
    }
    
    func clear_Interface_2(){
        for (name, label) in name_to_label_2{
            name_to_label_2[name]?.removeFromSuperview()
        }
        name_to_button["Confirm"]?.removeFromSuperview()
        name_to_button["Go Back"]?.removeFromSuperview()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //initalize the database
    func initDatabase(){
        let filemgr = NSFileManager.defaultManager()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        var databasePath = docsDir.stringByAppendingPathComponent(
            "mydata.db")
        self.database = FMDatabase(path: databasePath as String)

        if self.database.open(){
            let sql_command = "CREATE TABLE IF NOT EXISTS WORKERS (company_name TEXT, employee_name TEXT, date TEXT, location_1 TEXT, hour_1 TEXT, location_2 TEXT, hour_2 TEXT, location_3 TEXT, hour_3 TEXT)"
            if !self.database.executeStatements(sql_command) {
                println("Unable to create database")
            }
            self.database.close()
        }
        //self.searchName("")
        
    }
    


}

class PersonData{
    var company_name: String
    var employee_name: String
    var date: String
    var location_list: [String]
    var time_list: [String]

    class func get_between_time(start_time: String, end_time: String) -> String{
        //return the hours between start time and end time
        let INVALID_RESULT = "0h0m"
        var hour: String
        var min: String
        var start_hm = split(start_time) {$0 == ":"}        //[0] is hour and [1] is minute
        var end_hm = split(end_time) {$0 == ":"}
        
        if start_hm.count == 2 && end_hm.count == 2{        //check if the input format is valid
            var start_hour = start_hm[0].toInt()
            var start_min = start_hm[1].toInt()
            var end_hour = end_hm[0].toInt()
            var end_min = end_hm[1].toInt()
            
            //checking if input can be convert to integer
            if start_hour == nil || start_min == nil || end_hour == nil || end_min == nil {
                return INVALID_RESULT
            }
            
            if start_min > end_min{                     //check if start min is greater than end min
                end_hour = end_hour! - 1
                min = String(60 + end_min! - start_min!) + "m"
            }
            else{
                min = String(end_min! - start_min!) + "m"
            }
            if start_hour > end_hour{                   // you can't work for negative hours

                return INVALID_RESULT
            }
            else{
                hour = String(end_hour! - start_hour!) + "h"
            }
            return hour + min
        }
        else{
  
            return INVALID_RESULT
        }
    }
    // get the time between for all the time in the list
    class func get_time_list(st_list: [String], et_list: [String]) -> [String]{
        var result = [String]()
        for i in 0...(et_list.count - 1) {
            result.append(PersonData.get_between_time(st_list[i], end_time: et_list[i]))
        }
        return result
    }
    
    init(cn: String, en: String, date: String, location_list: [String], st_list: [String], et_list: [String]){
        self.company_name = cn
        self.employee_name = en
        self.date = date
        self.location_list = location_list
        self.time_list = PersonData.get_time_list(st_list, et_list: et_list)

    }
}

