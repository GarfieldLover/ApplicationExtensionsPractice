//
//  ContentBlockerRequestHandler.swift
//  ContentBlockerExtension
//
//  Created by zhangke on 16/8/4.
//
//

/*
 beta版只有block 能用
 */

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    //显示前请求blocker，解析action、trigger 阻止绘制
    func beginRequest(with context: NSExtensionContext) {
        let attachment = NSItemProvider(contentsOf: Bundle.main.urlForResource("blockerList", withExtension: "json"))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil);
    }
    
}
