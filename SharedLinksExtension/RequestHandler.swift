//
//  RequestHandler.swift
//  SharedLinksExtension
//
//  Created by ZK on 16/7/29.
//
//

import Foundation

class RequestHandler: NSObject, NSExtensionRequestHandling {
    
    //可以从app里把想要保存的url 自动保存到sharedLinks，比如指定一批收藏的视频地址
    //微博做了，好像是收藏或转发的微博
    
    //先在app里保存hero，用虫洞读取 object，图片可以读取url
    //虫洞可以开一个读取图片地址的接口
    func beginRequest(with context: NSExtensionContext) {
        let extensionItem = NSExtensionItem()
        
        // The keys of the user info dictionary match what data Safari is expecting for each Shared Links item.
        // For the date, use the publish date of the content being linked
        extensionItem.userInfo = [ "uniqueIdentifier": "uniqueIdentifierForSampleItem", "urlString": "http://collection.sina.com.cn/2016-04-08/doc-ifxrcizs7072851.shtml", "date": NSDate() ]
        
        extensionItem.attributedTitle = AttributedString(string: "安杜因洛萨")
        extensionItem.attributedContentText = AttributedString(string: "洛萨是暴风城的骑士也是阿拉希血统的唯一传人，他骁勇善战，曾担任过铁马兄弟会第七任会长、艾泽拉斯王国摄政王和洛丹伦联盟最高统帅。他将自己的一生献给了他的国家，为了艾泽拉斯的和平，身先士卒与兽人开战。当他得知莱恩国王独自率军进攻兽人部落时，他因身在卡拉赞，无法及时前往护驾。莱恩国王在战乱中牺牲，这彻彻底底激怒了洛萨。满腔怒火的他决定和邪恶的兽人将领布莱克汉?黑手决斗，并成功将其斩杀。此举赢得了大部分正义兽人战士的敬佩，他们决定让洛萨独自离开，停止无谓的厮杀。")
        
        // You can supply a custom image to be used with your link as well. Use the NSExtensionItem's attachments property.
         extensionItem.attachments = [NSItemProvider(contentsOf: Bundle.main.urlForResource("appicon", withExtension: "png"))!]

        context.completeRequest(returningItems: [extensionItem, extensionItem], completionHandler: nil)
    }

}
