//
//  ViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit

class PhotoCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var buttonSelectLabel: UILabel?

    var dataArray: NSMutableArray?
    var extensionsArray: NSMutableArray?

    var wormhole: MMWormhole?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataArray = NSMutableArray.init(contentsOfFile: Bundle.main().pathForResource("data", ofType: "plist")!)
        extensionsArray = NSMutableArray.init()
        
        wormhole = MMWormhole.init(applicationGroupIdentifier: "group.gl.ApplicationExtensionsPractice", optionalDirectory: "wormhole")
        wormhole?.listenForMessage(withIdentifier: "ShareExtension", listener: { (messageObject) in
            let name: String = messageObject as! String
            print(name)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (dataArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell
        let dataDic: NSDictionary = dataArray?.object(at: indexPath.item!) as! NSDictionary
        
        let imageName: NSString = dataDic.object(forKey: "imageName") as! NSString

        cell.photoView?.image = UIImage.init(named: imageName as String)
        cell.titleLabel?.text = dataDic.object(forKey: "title") as? String
        
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
        
        
        let dataDic: NSMutableDictionary = dataArray?.object(at: indexPath.item!) as! NSMutableDictionary
        let imageName: NSString = dataDic.object(forKey: "imageName") as! NSString

        let image: UIImage = UIImage.init(named: imageName as String)!
        let data: NSData = UIImageJPEGRepresentation(image, 1.0)!
        dataDic.setObject(data, forKey: "data")
        
        extensionsArray?.add(dataDic)
        
        if extensionsArray?.count > 5 {
            self.extensionsArray?.removeAllObjects()

            let alert: UIAlertController = UIAlertController.init(title: "已经存储", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction1: UIAlertAction = UIAlertAction.init(title: "删除", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                self.extensionsArray?.removeAllObjects()
            })
            let alertAction2: UIAlertAction = UIAlertAction.init(title: "ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
                userDefault.set(self.extensionsArray, forKey: "extensionsArray")
                userDefault.synchronize()
            })
            alert.addAction(alertAction1)
            alert.addAction(alertAction2)
            alert.show(self, sender: nil)
        }else{
            let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
            userDefault.set(self.extensionsArray, forKey: "extensionsArray")
            userDefault.synchronize()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let det: DetailViewController! = segue.destinationViewController as! DetailViewController
        det.dataDic = nil
    }
}

