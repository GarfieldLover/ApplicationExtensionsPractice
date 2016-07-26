//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit
import NotificationCenter

//xib 有大问题
class TodayTableViewCell: UITableViewCell {
     var imagePhoto: UIImageView?
     var imagePhotoTitle: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imagePhoto = UIImageView.init(frame: CGRect.init(x: 20, y: 6, width: 80, height: 40))
        self.addSubview(imagePhoto!)
        
        imagePhotoTitle = UILabel.init(frame: CGRect.init(x: 120, y: 6, width: 200, height: 40))
        self.addSubview(imagePhotoTitle!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imagePhoto1: UIImageView?
    @IBOutlet weak var imagePhoto2: UIImageView?
    @IBOutlet weak var imagePhotoTitle1: UILabel?
    @IBOutlet weak var imagePhotoTitle2: UILabel?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var waitingTitle: UILabel?
    @IBOutlet weak var noDataView: UIView?
    @IBOutlet weak var dataView: UIView?
    
    var extensionsArray: NSArray?
    
    var wormhole: MMWormhole?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wormhole = MMWormhole.init(applicationGroupIdentifier: "group.gl.ApplicationExtensionsPractice", optionalDirectory: "wormhole")

        //UI适配还的靠屏幕宽度计算得来
        
        waitingTitle?.isHidden = false

        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
        
        extensionsArray = userDefault.object(forKey: "extensionsArray") as? NSArray
         
        if (extensionsArray != nil && extensionsArray?.count>1) {
            
            let dic1: NSDictionary? = extensionsArray?.object(at: 0) as? NSDictionary
            var data: NSData? = dic1?.object(forKey: "data") as? NSData
            imagePhoto1?.image = UIImage.init(data: data as! Data)
            imagePhotoTitle1?.text = dic1?.object(forKey: "title") as? String
            
            let dic2: NSDictionary? = extensionsArray?.object(at: 1) as? NSDictionary
            data = dic2?.object(forKey: "data") as? NSData
            imagePhoto2?.image = UIImage.init(data: data as! Data)
            imagePhotoTitle2?.text = dic2?.object(forKey: "title") as? String
            
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
            
            noDataView?.isHidden = true
            dataView?.isHidden = false
            
            tableView?.reloadData()
            
        }else{
            
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact

            dataView?.isHidden = true
            noDataView?.isHidden = false
        }
        
        waitingTitle?.isHidden = true

        //app内选择人员
        //通知方式到extion
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(extensionsArray?.count>0){
            return (extensionsArray?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TodayTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "TodayTableViewCell") as? TodayTableViewCell
        if(cell == nil){
            cell = TodayTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "TodayTableViewCell")
        }
        
        let dic1: NSDictionary? = extensionsArray?.object(at: indexPath.row) as? NSDictionary
        let data: NSData? = dic1?.object(forKey: "data") as? NSData
        cell?.imagePhoto?.image = UIImage.init(data: data as! Data)
        cell?.imagePhotoTitle?.text = dic1?.object(forKey: "title") as? String
        
        return cell!
    }
    
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if(activeDisplayMode == NCWidgetDisplayMode.compact){
            self.preferredContentSize = maxSize;
        }else{
            self.preferredContentSize = CGSize.init(width: maxSize.width, height: 400);
        }
    }
    
    @IBAction func xxxx(){
        wormhole?.passMessageObject(title, identifier: "ShareExtension")

        //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"demonote:%ld", (long)indexPath.row]];
        let url: URL! = URL.init(string: "ApplicationExtensionsPractice:xxx");
        self.extensionContext?.open(url, completionHandler: { (Bool) in
            
        })
    }
    
    @IBAction func buttonSelect(button: UIButton?){
        //DarwinNotificationsManager.sharedInstance().postNotification(withName: "buttonSelect", object: button)
    }


}


