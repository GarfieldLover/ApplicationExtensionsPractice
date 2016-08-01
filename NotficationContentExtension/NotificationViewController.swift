//
//  NotificationViewController.swift
//  NotificationContent
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var sublabel: UILabel!
    
    var actionCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  custom content size of view
        self.preferredContentSize = CGSize(width: self.view.bounds.width, height: 300)
    }
    
    func dismissssss() {
        actionCompletion?()
        actionCompletion = nil
    }
}

extension NotificationViewController : UNNotificationContentExtension {
    
    //得到通知
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.label?.text = content.body
        
        //有自定义key, 用于远程通知nono，只是用于下载
        if let imageAbsoluteString = content.userInfo["imageAbsoluteString"] as? String,
            let url = URL(string: imageAbsoluteString) {
            URLSession.downloadImage(atURL: url) { [weak self] (data, error) in
                if let _ = error {
                    return
                }
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                    self?.imageView.isHidden = false
                }
            }
        }else {
            //附件形式, 远程通知下载完了也走这
            let attachment: UNNotificationAttachment = (content.attachments.first)!
            let url: URL = attachment.url
            let data: NSData = try! NSData.init(contentsOf: url)
            
            if content.categoryIdentifier == String.UNNotificationCategory.Image.rawValue {
                imageView.image = UIImage(data: data as Data)
            } else {
                imageView.image = UIImage.sd_animatedGIF(with: data as Data!)
            }
        }
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: (UNNotificationContentExtensionResponseOption) -> Void) {
        
        //  if response is UNTextInputNotificationResponse
        if let textInputResponse = response as? UNTextInputNotificationResponse {
            print(textInputResponse.userText)
            completion(.dismiss)
            return
        }
        
        
        //action跳转处理
        
        let responseNotificationRequestIdentifier = response.notification.request.identifier
    
        if responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushNormal.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithImage.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithGif.rawValue ||
            responseNotificationRequestIdentifier == String.UNNotificationRequest.LocalPushWithTrigger.rawValue {
            
            let actionIdentifier = response.actionIdentifier
            switch actionIdentifier {
            case String.UNNotificationAction.Accept.rawValue:
                sublabel.text = "Good"

                let url: URL! = URL.init(string: "ApplicationExtensionsPractice:NotifiAccept");
                self.extensionContext?.open(url, completionHandler: { (Bool) in
                    completion(.dismiss)
                })
                break
            case String.UNNotificationAction.Reject.rawValue:
                sublabel.text = "Don't allow reject，can't dismiss"
                completion(.dismiss)
                break
            case String.UNNotificationAction.Input.rawValue:
                becomeFirstResponder()
                break
            default:
                break
            }
        }
    }
}
