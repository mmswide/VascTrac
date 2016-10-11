//
//  Extensions.swift
//  Vasctrac
//
//  Created by Developer on 3/4/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import TextFieldEffects

extension Bool {
    init<T : IntegerType>(_ integer: T) {
        if integer == 0 {
            self.init(false)
        } else {
            self.init(true)
        }
    }
}

extension NSDate {
    private class func componentFlags() -> NSCalendarUnit { return [.Year, .Month, .Day, .Weekday] }
    
    class func getTodayHour() -> String {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([.Hour, .Minute], fromDate: NSDate())
        let hour = components.hour
        let minutes = components.minute
        return "Today, \(hour):\(minutes)"
    }
    
    func getDay() -> Int {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(NSDate.componentFlags(), fromDate: self)
        let day = components.day
        return day
    }
    
    func getMonth() -> String {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(NSDate.componentFlags(), fromDate: self)
        let month = formatter.shortMonthSymbols[components.month-1]
        return month
    }
    
    func timeToString() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    func longFormattedString() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .LongStyle, timeStyle: .NoStyle)
    }
    
    func fullFormattedString() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .FullStyle, timeStyle: .NoStyle)
    }
    
    class func dateFromComponents(components: NSDateComponents) -> NSDate? {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        return calendar?.dateFromComponents(components)
    }
    
    class func dateFromString(string: String) -> NSDate?  {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SSS"
        
        if let stringDate = dateFormatter.dateFromString(string) {
            return stringDate
        } else {
            return nil
        }
    }
    
    func ISOStringFromDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        // TODO: 
        // remove line below to prevent from manually adding "Z" (Z means UTC) we don't want this 
        return dateFormatter.stringFromDate(self).stringByAppendingString("Z")
        //return dateFormatter.stringFromDate(self)
    }
    
    class func dateFromISOString(string: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        
        if let stringDate = dateFormatter.dateFromString(string) {
            return stringDate
        } else {
            return nil
        }
    }
    
    public func isLessThanOneMinute(dateToCompare: NSDate) -> Bool {
        if abs(self.minutesFrom(dateToCompare)) < 1 {
            return true
        }
        return false
    }
    
    func minutesFrom(dateToCompare: NSDate) -> Int {
        return NSCalendar.currentCalendar().components([.Minute], fromDate: dateToCompare, toDate: self, options: []).minute
    }
    
    func daysTo(dateToCompare: NSDate) -> Int {
        return NSCalendar.currentCalendar().components([.Day], fromDate: self, toDate: dateToCompare, options: []).day
    }
    
    func dayByAdding(daysToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        guard let startOfDay = calendar.dateFromComponents(components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return calendar.dateByAddingUnit(.Day, value: daysToAdd, toDate: startOfDay, options: [])
    }
    
    func monthByAdding(monthsToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingUnit(.Month, value: monthsToAdd, toDate: self, options: [])
    }
    
    func startOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        guard let startOfDay = calendar.dateFromComponents(components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return startOfDay
    }
    
    func endOfDay() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        guard let startOfDay = calendar.dateFromComponents(components) else {
            fatalError("*** Unable to create the start date ***")
        }
        return calendar.dateByAddingUnit(.Day, value: 1, toDate: startOfDay, options: [])
    }
}

extension UIAlertController {
    
    class func errorAlert(alertMessage: String) -> UIAlertController {
        let errorTitle = "Error"
        let alert = UIAlertController(title: errorTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
}

extension Dictionary {
    mutating func append(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if  (view is UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        return nil
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

// add validation to HoshiTextField
extension HoshiTextField {
    
    func changePlaceholderText(text: String, withError error: Bool) {
        self.placeholderColor = error ? UIColor.redColor() : UIColor(white: 0.667, alpha: 0.7)
        self.placeholderFontScale = 0.65
        self.placeholder = text
    }
    
    func isValidEmail(withDefaultPlaceholderText defaultPlaceholderText: String) -> Bool {

        let emailValidationRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        if self.text!.isNotEmpty {
            if !NSPredicate(format: "SELF MATCHES %@", emailValidationRegex).evaluateWithObject(self.text) {
                self.changePlaceholderText("Please, enter valid email address", withError: true)
                return false
            }
        }
        self.changePlaceholderText(defaultPlaceholderText, withError: false)
        return true
    }
 
    func isValidPassword(withDefaultPlaceholderText defaultPlaceholderText: String) -> Bool {
        if self.text!.isNotEmpty {
            if self.text!.characters.count < 6 {
                self.changePlaceholderText("Must be at least 6 characters", withError: true)
                return false
            }
        }
        self.changePlaceholderText(defaultPlaceholderText, withError: false)
        return true
    }
    
    class func fieldsNotEmpty(inView view: UIView) -> Bool {
        view.endEditing(true) // this makes validation for each field
        
        for textField in view.subviewsOfType(HoshiTextField.self) {
            if textField.text!.isEmpty {
                textField.changePlaceholderText("This can’t be empty", withError: true)
                return false
            }
        }
        return true
    }
}

extension UIView {
    
    func subviewsOfType<T: UIView>(someClass: T.Type) -> [T] {
        var views = [T]()
        
        for subview in self.subviews {
            views += subview.subviewsOfType(T.self)
            
            if subview is T {
                views.append(subview as! T)
            }
        }
        return views
    }
}

extension Double {
    
    func metersToFeetString() -> String {
        // ft = m * 3.2808
        
        // correct conversion
        let feets = self.metersToFeet()
        let roundedFeets = ceil(feets * 100.0) / 100.0
        return String(roundedFeets)
        
        // TODO: feet to meter bug maybe here
//        let feets = (self*3.2808)/12
//        let roundedFeets = ceil(feets * 100.0) / 100.0
//        return String(roundedFeets)
        
        //
//        let heightInFeets = (self*3.2808)/12
//        let feets = Int(heightInFeets)
//        let inches = Int(ceil((heightInFeets - Double(feets))*10))
//        return "\(feets)'\(inches)''"
    }
    
    func metersToFeet() -> Double {
        // ft = m * 3.2808
        return (self*3.2808)
    }
}

// TODO: may need this extension for formatting dates
extension NSDate {
    var iso8601: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.stringFromDate(self)
    }
}
