//
//  Hero.swift
//  ApplicationExtensionsPractice
//
//  Created by ZK on 16/7/28.
//
//

import Foundation

class Hero : AnyObject {
    
    var heroID: String?
    var title: String?
    var imageName: String?
    var detail: String?
    var star: String?
    
    
    
    func initWithDic(dic: NSDictionary!) -> Hero {
        self = super.init
        
    }
    
    
}
