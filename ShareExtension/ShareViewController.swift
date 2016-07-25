//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by ZK on 16/7/25.
//
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    
    var articleTitle: String?
    var articleImage: String?
    var articleUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            self.articleTitle = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["title"] as? String
//                            self.articleHost = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["host"] as! String
//                            self.articleDesc = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["description"] as! String
                            self.articleImage = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["image"] as? String
                            self.articleUrl = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["url"] as? String
                            
                            self.addShareMenu()

                        }
                    })
                }
            }
        }
        
        
    }
    
    func addShareMenu(_: Void) -> Void {
        
        let storyboard: UIStoryboard = UIStoryboard.init(name: "MainInterface", bundle: Bundle.main())
        
        let nav: UINavigationController = storyboard.instantiateViewController(withIdentifier: "ShareMenuNav") as! UINavigationController
        nav.view.bounds.size = CGSize.init(width: 320, height: 300)
        nav.view.center = CGPoint.init(x: self.view.center.x, y: self.view.center.y)
        self.addChildViewController(nav)
        self.view.addSubview(nav.view)
        
//        let url: URL = URL.init(string: articleImage!)!
//        let task = URLSession.shared().downloadTask(with: url) { location, response, error in
//            guard location != nil && error == nil else {
//                print(error)
//                return
//            }
//            
////            let fileManager = FileManager.default()
////            let documents = try! fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
////            let fileURL = documents.URLByAppendingPathComponent("test.jpg")
////            do {
////                try fileManager.moveItemAtURL(location!, toURL: fileURL)
////            } catch {
////                print(error)
////            }
//        }
//
//        task.resume()
        
        let shareMenu: ShareMenuViewController = nav.visibleViewController as! ShareMenuViewController
//        shareMenu.imageView?.image = UIImage.init(data: <#T##Data#>)
        shareMenu.titleLabel?.text = articleTitle
        shareMenu.detailLabel?.text = articleUrl

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "patternDetailSegue" {
        }
    }
    
#if false
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
#endif
}


class ShareMenuViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    
}

