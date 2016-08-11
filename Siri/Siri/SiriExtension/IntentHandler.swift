//
//  IntentHandler.swift
//  SiriExtension
//
//  Created by zhangke on 16/8/8.
//
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

//创建通讯录－> 输入：发送信息给xx－>siri匹配人、内容－>确认匹配->app发送信息，并UI展示

class IntentHandler: INExtension, INSendMessageIntentHandling{
    
    override func handler(for intent: INIntent) -> AnyObject {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    //在Siri获取到用户的语音输入之后，生成一个INIntent对象，将语音中的关键信息提取出来并且填充对应的属性
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(forSendMessage intent: INSendMessageIntent, with completion: ([INPersonResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INPersonResolutionResult.needsValue()])
            }
            
            var resolutionResults = [INPersonResolutionResult]()
            for recipient in recipients {
                //对比通讯录得出结果
                let matchingContacts = UCAddressBookManager().contacts(matchingName: recipient.displayName)
                switch matchingContacts.count {
                case 2  ... Int.max:
                    //返回数组，让siri选一个
                    // We need Siri's help to ask user to pick one from the matches.
                    let disambiguationOptions: [INPerson] = matchingContacts.map { contact in
                        return contact.inPerson()
                    }
                    
                    resolutionResults += [.disambiguation(with: disambiguationOptions)]
                    
                case 1:
                    //有一个直接返回
                    // We have exactly one matching contact
                    let recipientMatched = matchingContacts[0].inPerson()
                    resolutionResults += [.success(with: recipientMatched)]
                    
                case 0:
                    // We have no contacts matching the description provided
                      resolutionResults += [.unsupported()]
                    
                default:
                    break
                    
                }
            }
            completion(resolutionResults)
        }
    }
    
    func resolveContent(forSendMessage intent: INSendMessageIntent, with completion: (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    //依次调用confirm打头的实例方法来判断Siri填充的信息是否完成。匹配的判断结果包括Exactly one match、Two or more matches以及No match三种情况
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(sendMessage intent: INSendMessageIntent, completion: (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        if UCAccount.shared().hasValidAuthentication {
            completion(INSendMessageIntentResponse(code: .success, userActivity: nil))
        }
        else {
            // Creating our own user activity to include error information.
            let userActivity = NSUserActivity(activityType: String(INSendMessageIntent.self))
            userActivity.userInfo = [NSString(string: "error"):NSString(string: "UserLoggedOut")]
            
            completion(INSendMessageIntentResponse(code: .failureRequiringAppLaunch, userActivity: userActivity))
        }
    }
    
    //在confirm方法执行完成之后，Siri进行最后的处理阶段，生成答复对象，并且向此intent对象确认处理结果然后执显示结果给用户看
    // Handle the completed intent (required).
    
    func handle(sendMessage intent: INSendMessageIntent, completion: (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        if intent.recipients != nil && intent.content != nil {
            // Send the message.
            //微信发送
            let success = UCAccount.shared().sendMessage(intent.content, toRecipients: intent.recipients)
            completion(INSendMessageIntentResponse(code: success ? .success : .failure, userActivity: nil))
        }
        else {
            completion(INSendMessageIntentResponse(code: .failure, userActivity: nil))
        }
    }
    
}
