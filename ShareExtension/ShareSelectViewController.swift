//
//  ShareSelectViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by ZK on 16/7/25.
//
//

import Foundation
import UIKit

class ShareSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var extensionsArray: NSArray?
    var wormhole: MMWormhole?
    var index: Int?
    
//    var shareVC: UIViewController?

    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "发送", style: UIBarButtonItemStyle.done, target: self, action: #selector(sendToApp))
        self.navigationItem.title = "选择"
        
        let userDefault: UserDefaults! = UserDefaults.init(suiteName: "group.gl.ApplicationExtensionsPractice")
        extensionsArray = userDefault.object(forKey: "extensionsArray") as? NSArray
        
        wormhole = MMWormhole.init(applicationGroupIdentifier: "group.gl.ApplicationExtensionsPractice", optionalDirectory: "wormhole")
    }
    
    func sendToApp() -> Void {
        let dic1: NSDictionary? = extensionsArray?.object(at: index!) as? NSDictionary
        let title: String = (dic1?.object(forKey: "title") as? String)!
        wormhole?.passMessageObject(title, identifier: "ShareExtension")
        
        let nav: UINavigationController? = self.navigationController
        
        UIView .animate(withDuration: 0.25, animations: { 
            nav?.view.center = CGPoint.init(x: UIScreen.main().bounds.size.width/2, y: UIScreen.main().bounds.size.height+250.0/2)
        }) { (com) in
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(extensionsArray?.count>0){
            return (extensionsArray?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ShareMenuTableViewCell")
        if(cell == nil){
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "ShareMenuTableViewCell")
        }
        
        let dic1: NSDictionary? = extensionsArray?.object(at: indexPath.row) as? NSDictionary
        cell?.textLabel?.text = dic1?.object(forKey: "title") as? String
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            index = indexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.none
    }
}
