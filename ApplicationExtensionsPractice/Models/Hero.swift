//
//  Hero.swift
//  ApplicationExtensionsPractice
//
//  Created by ZK on 16/7/28.
//
//

import Foundation

class Hero : AnyObject, NSCoding {
    
    var heroID: String?
    var title: String?
    var imageName: String?
    var detail: String?
    var star: String?
    
    init() {
    
    }

    
    func update(_ dictionary: Dictionary<String, AnyObject>) {
        
        heroID = dictionary["imageName"] as? String
        title = dictionary["title"] as? String
        imageName = dictionary["imageName"] as? String
        detail = dictionary["detail"] as? String
        star = dictionary["star"] as? String

    }
    required init?(coder aDecoder: NSCoder) {
        heroID = aDecoder.decodeObject(forKey: "heroID") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String
        imageName = aDecoder.decodeObject(forKey: "imageName") as? String
        detail = aDecoder.decodeObject(forKey: "detail") as? String
        star = aDecoder.decodeObject(forKey: "star") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(heroID, forKey: "heroID")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(imageName, forKey: "imageName")
        aCoder.encode(detail, forKey: "detail")
        aCoder.encode(star, forKey: "star")
    }


}
