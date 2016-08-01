//
//  Extension.swift
//  NotificationDemo
//
//


import Foundation

extension String {
    
    enum UNNotificationAction : String {
        case Accept
        case Reject
        case Input
    }
    
    enum UNNotificationCategory : String {
        case Normal
        case Image
        case Gif
    }
    
    enum UNNotificationRequest : String {
        case LocalPushNormal
        case LocalPushWithImage
        case LocalPushWithGif
        case LocalPushWithTrigger
    }
}

extension URL {
    
    enum ResourceType : String {
        case Image
        case Gif
        case Remote
    }
    
    static func resource(type :ResourceType) -> URL {
        switch type {
        case .Image:
            return Bundle.main.urlForResource("2016060810591211", withExtension: "jpg")!
        case .Gif:
            return Bundle.main.urlForResource("hahaha", withExtension: "gif")!
        case .Remote:
            return URL(string: "http://www.jlonline.com/uploads/allimg/151103/133522O20-0.jpg")!
        }
    }
}

extension URLSession {
    
    class func downloadImage(atURL url: URL, withCompletionHandler completionHandler: (Data?, NSError?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            completionHandler(data, error)
        }
        dataTask.resume()
    }
}

