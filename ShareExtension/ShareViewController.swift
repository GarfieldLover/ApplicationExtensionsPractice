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
    
    var shareMenu: ShareMenuViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addShareMenu()

        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            
                            self.shareMenu?.setResult(resultDict: resultDict)

                        }
                    })
                }
            }
        }
        
    }
    
    func addShareMenu(_: Void) -> Void {
        
        let storyboard: UIStoryboard = UIStoryboard.init(name: "MainInterface", bundle: Bundle.main())
        
        shareMenu = storyboard.instantiateViewController(withIdentifier: "ShareMenu") as? ShareMenuViewController
        let nav: UINavigationController = UINavigationController.init(rootViewController: shareMenu!)
        shareMenu?.shareVC = self
        
        nav.view.bounds.size = CGSize.init(width: 320, height: 250)
        self.addChildViewController(nav)
        self.view.addSubview(nav.view)
        
        nav.view.layer.cornerRadius = 10
        nav.view.layer.masksToBounds = true
        
        nav.view.center = CGPoint.init(x: self.view.center.x, y: self.view.bounds.size.height+250.0/2)

        UIView.animate(withDuration: 0.25) { 
            nav.view.center = CGPoint.init(x: self.view.center.x, y: self.view.center.y)
        }

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


