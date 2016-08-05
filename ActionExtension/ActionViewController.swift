//
//  ActionViewController.swift
//  ActionExtension
//
//  Created by ZK on 16/8/5.
//
//

/*
 beta版各种bug，webview加载不了， 
 */

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?){
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.webView.delegate = self

            let url: URL = URL.init(string: "http://wow.178.com/phone.html")!
            let request: URLRequest = URLRequest.init(url: url)
            self.webView.loadRequest(request)
            
        }
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, UIScreen.main().scale)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();

//        let image: UIImage? = webView.screenshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        
        
        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            
                        }
                    })
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
