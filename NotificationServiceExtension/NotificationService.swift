//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by zhangke on 16/7/29.
//
//


/*
 Service push data struct:
 
 {
    "aps" : {
        "alert" : {
        "title" : "title",
        "body" : "Your message Here"
        },
        "mutable-content" : "1",
        "category" : "Image"    //  if needn't use custom extensionContent, delete it.
    },
    "imageAbsoluteString" : "http://ww1.sinaimg.cn/large/65312d9agw1f59leskkcij20cs0csmym.jpg"  //  custom info
 }
 */

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    //应该是远程通知接受，把imageAbsoluteString下载，组成attachement调用UNNotificationContentExtension
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler:(UNNotificationContent) -> Void) {
        let content = request.content

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        //  get app group fmURL. If you reset group, remember reset GroupIdentifier
        let fmURL: URL? = FileManager.default.containerURLForSecurityApplicationGroupIdentifier("group.gl.ApplicationExtensionsPractice")
        
        var attachement: UNNotificationAttachment? = nil
        
        //  use semaphore convert async download to sync
        let semaphore = DispatchSemaphore(value: 0)
        
        let imageAbsoluteString = content.userInfo["imageAbsoluteString"] as? String
        let url = URL(string: imageAbsoluteString!)
        
        URLSession.downloadImage(atURL: url!) { (data, error) in
            
            var url: URL? = nil
            do {
                //保存为取个id吧
                //  have to set file extension which support by UNNotificationAttachment, png, jpeg, gif...
                url = try fmURL?.appendingPathComponent("customAttachmentPic").appendingPathExtension(".png")
            }
            catch {
                // out put error by notification
                if let bestAttemptContent = self.bestAttemptContent {
                    bestAttemptContent.title = "customAttachmentPic"
                    bestAttemptContent.body = String(error)
                    contentHandler(bestAttemptContent)
                    return
                }
            }
            
            //存储文件 png
            //  write to app group file url
            try! data?.write(to: url!)
            
            //创建attachement
            //  create UNNotificationAttachment by app group file url
            attachement = try! UNNotificationAttachment(identifier: "attachment", url: url!, options: nil)
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        //传入附件，调用contentHandler
        //  success set attachments
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            bestAttemptContent.attachments = [attachement!]
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
