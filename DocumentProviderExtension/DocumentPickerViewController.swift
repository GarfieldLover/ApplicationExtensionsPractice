//
//  DocumentPickerViewController.swift
//  DocumentProviderExtension
//
//  Created by ZK on 16/8/2.
//
//

import UIKit

class DocumentPickerViewController: UIDocumentPickerExtensionViewController {

    @IBAction func openDocument(_ sender: AnyObject?) {
        let documentURL = try! self.documentStorageURL!.appendingPathComponent("Untitled.txt")
        
        // TODO: if you do not have a corresponding file provider, you must ensure that the URL returned here is backed by a file
        self.dismissGrantingAccess(to: documentURL)
    }
    
    override func prepareForPresentation(in mode: UIDocumentPickerMode) {
        // TODO: present a view controller appropriate for picker mode here
    }

}
