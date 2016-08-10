//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by zhangke on 16/8/4.
//
//

/*
 当然可以通过主app 虫洞把数据传过来，直接读数组传到黑名单里，可惜拿不到各家的黑名单
 */

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        //先判断是否成功调用了 retrievePhoneNumbersToBlock 方法，如果没有，则打印 Log： Unable to retrieve phone numbers to block，然后直接终止这次请求并返回。
        guard let phoneNumbersToBlock = retrievePhoneNumbersToBlock() else {
            NSLog("Unable to retrieve phone numbers to block")
            let error = NSError(domain: "CallDirectoryHandler", code: 1, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        //遍历添加黑名单中的号码，这里的号码将直接拦截。
        for phoneNumber in phoneNumbersToBlock {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
        
        //先判断是否成功调用了 retrievePhoneNumbersToIdentifyAndLabels 方法，如果没有，则打印 Log： Unable to retrieve phone numbers to identify and their labels，然后直接终止这次请求并返回。
        guard let (phoneNumbersToIdentify, phoneNumberIdentificationLabels) = retrievePhoneNumbersToIdentifyAndLabels() else {
            NSLog("Unable to retrieve phone numbers to identify and their labels")
            let error = NSError(domain: "CallDirectoryHandler", code: 2, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        //遍历添加识别后的号码及其描述，这里的号码将连带描述一起显示。
        for (phoneNumber, label) in zip(phoneNumbersToIdentify, phoneNumberIdentificationLabels) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }
        
        //完成提交请求。
        context.completeRequest()
    }
    
    private func retrievePhoneNumbersToBlock() -> [String]? {
        // retrieve list of phone numbers to block
        return ["+8618910764279"]
    }
    
    private func retrievePhoneNumbersToIdentifyAndLabels() -> (phoneNumbers: [String], labels: [String])? {
        // retrieve list of phone numbers to identify, and their labels
        return (["+8618910764279"], ["骚扰电话"])
    }
    
}
