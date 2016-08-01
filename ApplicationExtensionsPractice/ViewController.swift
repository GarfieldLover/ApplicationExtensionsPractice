//
//  ViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit
import CoreSpotlight
import UserNotifications

class PhotoCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var buttonSelectLabel: UILabel?

    let dataArray: NSMutableArray = NSMutableArray.init()
    let extensionsArray: NSMutableArray = NSMutableArray.init()

    var wormhole: MMWormhole?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array: NSArray = NSArray.init(contentsOfFile: Bundle.main.pathForResource("data", ofType: "plist")!)!
        for dic in array {
            let hero: Hero = Hero()
            hero.update(dic as! Dictionary<String, AnyObject>)
            dataArray.add(hero)
            self.saveSpotlightItem(hero: hero)
        }
        
        wormhole = MMWormhole.init(applicationGroupIdentifier: "group.gl.ApplicationExtensionsPractice", optionalDirectory: "wormhole")
        wormhole?.listenForMessage(withIdentifier: "ShareExtension", listener: { (messageObject) in
            let name: String = messageObject as! String
            print(name)
        })
        
        
        self.setNotificationCategories()
    }
    
    
    //当然包括下载和缓存item
    func saveSpotlightItem(hero aHero: Hero) -> Void {
        //先删除索引
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [aHero.heroID!]) { (error) in
            
        }
        
        let searchableItemAttributeSet: CSSearchableItemAttributeSet = CSSearchableItemAttributeSet.init(itemContentType: "ApplicationExtensionsPractice")
        searchableItemAttributeSet.title = aHero.title
        searchableItemAttributeSet.contentDescription = aHero.detail
        searchableItemAttributeSet.thumbnailData = UIImageJPEGRepresentation(UIImage.init(named: aHero.imageName!)!, 1.0)
        searchableItemAttributeSet.rating = NSNumber.init(value: Int(aHero.star!)!)
        let searchableItem: CSSearchableItem = CSSearchableItem.init(uniqueIdentifier: aHero.heroID, domainIdentifier: "Hero", attributeSet: searchableItemAttributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([searchableItem]) { (error) in
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell
        
        let hero: Hero = dataArray.object(at: indexPath.item) as! Hero

        cell.photoView?.image = UIImage.init(named: hero.imageName! as String)
        cell.titleLabel?.text = hero.title
        
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let dataDic: NSDictionary! = dataArray?.object(at: indexPath.item) as! NSDictionary
//
//        let detailVC: DetailViewController! = DetailViewController.init(nibName: "DetailViewController", bundle: Bundle.main)
//        detailVC.dataDic = dataDic
//        
//        self.present(detailVC, animated: true, completion: nil)
//        self.performSegue(withIdentifier: "goDetail", sender: self)
        
        
//        storyboard 有问题
        
        let cell: PhotoCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell
        
        if (cell.titleLabel?.isHighlighted == false) {
            cell.titleLabel?.isHighlighted = true
        }else{
            cell.titleLabel?.isHighlighted = false
        }
        
        let hero: Hero = dataArray.object(at: indexPath.item) as! Hero
        
        extensionsArray.add(hero)
        
        //You can only store things like NSArray, NSDictionary, NSString, NSData, NSNumber, and NSDate in NSUserDefaults.
        
        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")

        if extensionsArray.count > 5 {
            self.extensionsArray.removeAllObjects()

            let alert: UIAlertController = UIAlertController.init(title: "已经存储", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction1: UIAlertAction = UIAlertAction.init(title: "删除", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                self.extensionsArray.removeAllObjects()
            })
            let alertAction2: UIAlertAction = UIAlertAction.init(title: "ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                
                let dataArray: NSMutableArray = NSMutableArray.init()
                for hero in self.extensionsArray {
                    let archivedData: Data = NSKeyedArchiver.archivedData(withRootObject: hero)
                    dataArray.add(archivedData)
                }
                userDefault.set(dataArray, forKey: "extensionsArray")
                userDefault.synchronize()
            })
            alert.addAction(alertAction1)
            alert.addAction(alertAction2)
            alert.show(self, sender: nil)
        }else{
            
            let dataArray: NSMutableArray = NSMutableArray.init()
            for hero in extensionsArray {
                let archivedData: Data = NSKeyedArchiver.archivedData(withRootObject: hero)
                dataArray.add(archivedData)
            }
            userDefault.set(dataArray, forKey: "extensionsArray")
            userDefault.synchronize()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let det: DetailViewController! = segue.destinationViewController as! DetailViewController
        det.dataDic = nil
    }
    
    func setNotificationCategories(_: Void) -> Void {
        let center = UNUserNotificationCenter.current()
        
        // create Notification Action
        let accept = UNNotificationAction(identifier: String.UNNotificationAction.Accept.rawValue,
                                          title: "Agree",
                                          options: UNNotificationActionOptions.foreground)
        
        let reject = UNNotificationAction(identifier: String.UNNotificationAction.Reject.rawValue,
                                          title: "DisAgree",
                                          options: UNNotificationActionOptions.destructive)
        
        let comment = UNTextInputNotificationAction(identifier: String.UNNotificationAction.Input.rawValue,
                                                    title: "Input Someting",
                                                    options: [],
                                                    textInputButtonTitle: "Comment",
                                                    textInputPlaceholder: "Input Someting")
        
        let normal =  UNNotificationCategory.init(identifier: String.UNNotificationCategory.Normal.rawValue, actions: [accept, reject], intentIdentifiers: [], options: [])
        let Image =  UNNotificationCategory.init(identifier: String.UNNotificationCategory.Image.rawValue, actions: [accept, reject], intentIdentifiers: [], options: [])
        let Gif =  UNNotificationCategory.init(identifier: String.UNNotificationCategory.Gif.rawValue, actions: [accept, reject, comment], intentIdentifiers: [], options: [])
        
        //注册通知类型
        //  add category to notification center categroies
        center.setNotificationCategories([normal, Image, Gif])
    }
    
    @IBAction func LocalPushNormal(_ sender: AnyObject) {
        
        //  1. Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "LocalPushNormal",
                                                                 arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "安杜因洛萨",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = String.UNNotificationCategory.Normal.rawValue   //  设置通知类型标示
        
        //  3. Create Notification Request
        let request = UNNotificationRequest.init(identifier: String.UNNotificationRequest.LocalPushNormal.rawValue,
                                                 content: content, trigger: nil)
        
        //  4. Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    @IBAction func LocalPushWithImage(_ sender: AnyObject) {
        
        //  1. Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "LocalPushWithImage",
                                                                 arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "安杜因洛萨",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = String.UNNotificationCategory.Image.rawValue   //  设置通知类型标示
        
        //  2. Create Notification Attachment
        let attachement = try? UNNotificationAttachment(identifier: "attachment", url: URL.resource(type: .Image), options: nil)
        content.attachments = [attachement!]
        
        //  3. Create Notification Request
        let request = UNNotificationRequest.init(identifier: String.UNNotificationRequest.LocalPushWithImage.rawValue,
                                                 content: content, trigger: nil)
        
        //  4. Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    @IBAction func LocalPushWithGif(_ sender: AnyObject) {
        
        //  1. Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "LocalPushWithGif",
                                                                 arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "安杜因洛萨",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = String.UNNotificationCategory.Gif.rawValue   //  设置通知类型标示
        
        //  2. Create Notification Attachment
        let attachement = try? UNNotificationAttachment(identifier: "attachment", url: URL.resource(type: .Gif), options: nil)
        content.attachments = [attachement!]
        
        //  3. Create Notification Request
        let request = UNNotificationRequest.init(identifier: String.UNNotificationRequest.LocalPushWithGif.rawValue,
                                                 content: content, trigger: nil)
        
        //  4. Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    @IBAction func remotePush(_ sender: AnyObject) {
        
        //  1. Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "remotePush",
                                                                 arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅帅",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = String.UNNotificationCategory.Image.rawValue   //  设置通知类型标示
        content.userInfo["imageAbsoluteString"] = URL.resource(type: .Remote).absoluteString
        
        let request = UNNotificationRequest.init(identifier: String.UNNotificationRequest.LocalPushNormal.rawValue,
                                                 content: content,
                                                 trigger: nil)
        
        //  4. Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    @IBAction func localPushWithTrigger(_ sender: AnyObject) {
        
        //  1. Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "localPushWithTrigger",
                                                                 arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "安杜因洛萨",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared().applicationIconBadgeNumber + 1;
        content.categoryIdentifier = String.UNNotificationCategory.Normal.rawValue   //  设置通知类型标示
        
        //  2. Create trigger
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        
        //  3. Create Notification Request，set content and trigger
        let request = UNNotificationRequest.init(identifier: String.UNNotificationRequest.LocalPushWithTrigger.rawValue,
                                                 content: content,
                                                 trigger: trigger)
        
        //  4. Add to NotificationCenter
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }

    
    //  MARK: Remove Notification
    @IBAction func removeNotify(_ sender: AnyObject) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//          remove specified notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String.UNNotificationRequest.LocalPushWithTrigger.rawValue])
    }

}

