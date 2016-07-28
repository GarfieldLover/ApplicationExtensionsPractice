//
//  CourseList.swift
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/28.
//
//

import Foundation

class CourseList: NSObject, NSCoding
{
    var myCourses: Dictionary<String, String>?
    
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.myCourses  = aDecoder.decodeObject(forKey: "myCourses") as? Dictionary
    }
    
    func encode(with aCoder: NSCoder) {
        if let courses = self.myCourses{
            aCoder.encode(courses, forKey: "myCourses")
        }
    }
    
    func populateCourses() {
        self.myCourses = ["cs101": "Hello World"]
    }
    
    func save() {
        let archivedData: Data = NSKeyedArchiver.archivedData(withRootObject: self)
        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")

        userDefault.set(archivedData, forKey: "archivedData")
    }
    
    func clear() {
        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
        
        userDefault.removeObject(forKey: "courseList")
    }
    
    class func loadSaved() -> CourseList? {
        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")

        if let data: Data = userDefault.object(forKey: "courseList") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? CourseList
        }
        return nil
    }
}
