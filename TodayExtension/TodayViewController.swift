//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by zhangke on 16/7/19.
//
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imagePhoto1: UIImageView?
    @IBOutlet weak var imagePhoto2: UIImageView?
    @IBOutlet weak var imagePhotoTitle1: UILabel?
    @IBOutlet weak var imagePhotoTitle2: UILabel?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var waitingTitle: UILabel?
    @IBOutlet weak var noDataView: UIView?
    @IBOutlet weak var dataView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        //UI适配还的靠屏幕宽度计算得来
        
        waitingTitle?.isHidden = false

        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
        
        let imageDic: NSDictionary? = userDefault.object(forKey: "imageDic") as? NSDictionary
        if let _ = imageDic {
            let imageData1: Data = imageDic!.object(forKey: "today_top1") as! Data
            let image1: UIImage = UIImage.init(data: imageData1)!
            imagePhoto1?.image = image1
            
            let imageData2: Data = imageDic!.object(forKey: "today_top2") as! Data
            let image2: UIImage = UIImage.init(data: imageData2)!
            imagePhoto2?.image = image2
            
            let imageTitle1: String = imageDic!.object(forKey: "today_top_title1") as! String
            imagePhotoTitle1?.text = imageTitle1
            
            let imageTitle2: String = imageDic!.object(forKey: "today_top_title2") as! String
            imagePhotoTitle2?.text = imageTitle2
            
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
            
            noDataView?.isHidden = true
            dataView?.isHidden = false
            
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
        return 5;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if(cell == nil){
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
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
        //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"demonote:%ld", (long)indexPath.row]];
        let url: URL! = URL.init(string: "ApplicationExtensionsPractice:xxx");
        self.extensionContext?.open(url, completionHandler: { (Bool) in
            
        })
    }

}


