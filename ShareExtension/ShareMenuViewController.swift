//
//  ShareMenuViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by ZK on 16/7/25.
//
//

import Foundation
import UIKit

class ShareMenuTableViewCell: UITableViewCell {
    var imagePhoto: UIImageView?
    var imagePhotoTitle: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imagePhoto = UIImageView.init(frame: CGRect.init(x: 20, y: 12, width: 20, height: 20))
        self.addSubview(imagePhoto!)
        
        imagePhotoTitle = UILabel.init(frame: CGRect.init(x: 60, y: 6, width: 150, height: 30))
        self.addSubview(imagePhotoTitle!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class ShareMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    
    var shareVC: UIViewController?

    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelVC))
        self.navigationItem.title = "Share"
    }
    
    func cancelVC() -> Void {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        let error: NSError = NSError.init()
        shareVC?.extensionContext!.cancelRequest(withError: error)
    }
    
    func setResult(resultDict: NSDictionary) -> Void {
        let title: String? = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["title"] as? String
        let url: String? = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["url"] as? String
        let image: String? = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["image"] as? String
        titleLabel?.text = title
        detailLabel?.text = url
        
        
        let imageUrl: URL = URL.init(string: image!)!
        let session: URLSession = URLSession.shared
        
        let task =  session.downloadTask(with: imageUrl) { (location, response, error) in
            //            imageView?.image = UIImage.init(data: <#T##Data#>)
        }

        task.resume()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ShareMenuTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ShareMenuTableViewCell") as? ShareMenuTableViewCell
        if(cell == nil){
            cell = ShareMenuTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "ShareMenuTableViewCell")
        }
        
        if indexPath.row == 0 {
            cell?.imagePhoto?.image = UIImage.init(named: "addedTaskAnim")
            cell?.imagePhotoTitle?.text = "发送给朋友"
        }else if indexPath.row == 1 {
            cell?.imagePhoto?.image = UIImage.init(named: "autodelete-Close")
            cell?.imagePhotoTitle?.text = "分享到朋友圈"
        }else {
            cell?.imagePhoto?.image = UIImage.init(named: "Download-Icon-Ask")
            cell?.imagePhotoTitle?.text = "收藏"
        }
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {

            let storyboard: UIStoryboard = UIStoryboard.init(name: "MainInterface", bundle: Bundle.main)
            let shareSelect: UIViewController = storyboard.instantiateViewController(withIdentifier: "ShareSelect")
            let shareSelectVC: ShareSelectViewController = shareSelect as! ShareSelectViewController
            let nav: UINavigationController = self.navigationController!
            nav.pushViewController(shareSelectVC, animated: true)
        }else if indexPath.row == 1 {

        }else {

        }
    }
    
}
