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
        
        let menu: ShareMenuViewController = ShareMenuViewController.init()
        self.addChildViewController(menu)
        self.view.addSubview(menu.view)
        
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
                        }
                    })
                }
            }
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
