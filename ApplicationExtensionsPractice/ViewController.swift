//
//  ViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit
import CoreSpotlight

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
        
        if CourseList.loadSaved() != nil {
            print("loaded Save CourseList")
        } else {
            // Create a new Course List
            let courseLs: CourseList = CourseList()
            courseLs.populateCourses()
            courseLs.save()
        }

        
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
}

