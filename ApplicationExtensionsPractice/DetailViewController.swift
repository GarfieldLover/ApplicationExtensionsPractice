//
//  DetailViewController.swift
//  ApplicationExtensionsPractice
//
//  Created by ZK on 16/7/22.
//
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView?
    @IBOutlet weak var detailView: UITextView?
    
    var dataDic: NSDictionary?
    
    override func viewDidLoad() {
        
//        let imageName: NSString = dataDic!.object(forKey: "imageName") as! NSString
//        photoView?.image = UIImage.init(named: imageName as String)
//        
//        detailView?.text = dataDic!.object(forKey: "detail") as! String
    }
    
    @IBAction func closeDetailViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
