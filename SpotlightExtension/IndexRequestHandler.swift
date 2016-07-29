//
//  IndexRequestHandler.swift
//  SpotlightExtension
//
//  Created by ZK on 16/7/28.
//
//

import CoreSpotlight

class IndexRequestHandler: CSIndexExtensionRequestHandler {
    
    //Core Spotlight app extension 可以在程序不运行的情况下也能对索引进行维护
    
    //不懂这2个方法，应该是系统调用吧，重建所有索引或者某组
    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: () -> Void) {
        // Reindex all data with the provided index
        
        acknowledgementHandler()
    }

    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: () -> Void) {
        // Reindex any items with the given identifiers and the provided index
        
        acknowledgementHandler()
    }

}
