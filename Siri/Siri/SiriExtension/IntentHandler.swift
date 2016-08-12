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

class IntentHandler: INExtension, INSendMessageIntentHandling, INStartVideoCallIntentHandling, INSendPaymentIntentHandling{
    
    override func handler(for intent: INIntent) -> AnyObject {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    //给谁
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
    
    //发什么
    func resolveContent(forSendMessage intent: INSendMessageIntent, with completion: (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    //询问是否发送
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
    
    
    // MARK: - INStartVideoCallIntent
    //给谁发
    func resolveContacts(forStartVideoCall intent: INStartVideoCallIntent, with completion: ([INPersonResolutionResult]) -> Swift.Void){
    }

    //确认发
    func confirm(startVideoCall intent: INStartVideoCallIntent, completion: (INStartVideoCallIntentResponse) -> Swift.Void){
    }
    
    //发
    func handle(startVideoCall intent: INStartVideoCallIntent, completion: (INStartVideoCallIntentResponse) -> Swift.Void){
    }
    
    // MARK: - INSendPaymentIntent
    func handle(sendPayment intent: INSendPaymentIntent, completion: (INSendPaymentIntentResponse) -> Swift.Void){
    }
    
    func confirm(sendPayment intent: INSendPaymentIntent, completion: (INSendPaymentIntentResponse) -> Swift.Void){}
    
    //收款人
    func resolvePayee(forSendPayment intent: INSendPaymentIntent, with completion: (INPersonResolutionResult) -> Swift.Void){}
    //货币金额
    func resolveCurrencyAmount(forSendPayment intent: INSendPaymentIntent, with completion: (INCurrencyAmountResolutionResult) -> Swift.Void){}
    //备注
    func resolveNote(forSendPayment intent: INSendPaymentIntent, with completion: (INStringResolutionResult) -> Swift.Void){}
    
    // MARK: - INSearchForPhotosIntent
    func handle(searchForPhotos intent: INSearchForPhotosIntent, completion: (INSearchForPhotosIntentResponse) -> Swift.Void){}

    func confirm(searchForPhotos intent: INSearchForPhotosIntent, completion: (INSearchForPhotosIntentResponse) -> Swift.Void){}
    //创建时间
    func resolveDateCreated(forSearchForPhotos intent: INSearchForPhotosIntent, with completion: (INDateComponentsRangeResolutionResult) -> Swift.Void){}
    //创建地点
    func resolveLocationCreated(forSearchForPhotos intent: INSearchForPhotosIntent, with completion: (INPlacemarkResolutionResult) -> Swift.Void){}
    //相册
    func resolveAlbumName(forSearchForPhotos intent: INSearchForPhotosIntent, with completion: (INStringResolutionResult) -> Swift.Void){}
    //INPerson 人名
    func resolvePeopleInPhoto(forSearchForPhotos intent: INSearchForPhotosIntent, with completion: ([INPersonResolutionResult]) -> Swift.Void){}
    
    
    // MARK: - INStartWorkoutIntent
    func handle(startWorkout intent: INStartWorkoutIntent, completion: (INStartWorkoutIntentResponse) -> Swift.Void){}

    func confirm(startWorkout intent: INStartWorkoutIntent, completion: (INStartWorkoutIntentResponse) -> Swift.Void){}

    //锻炼名称
    func resolveWorkoutName(forStartWorkout intent: INStartWorkoutIntent, with completion: (INSpeakableStringResolutionResult) -> Swift.Void){}
    //目标值
    func resolveGoalValue(forStartWorkout intent: INStartWorkoutIntent, with completion: (INDoubleResolutionResult) -> Swift.Void){}
    //锻炼目标单位类型
    func resolveWorkoutGoalUnitType(forStartWorkout intent: INStartWorkoutIntent, with completion: (INWorkoutGoalUnitTypeResolutionResult) -> Swift.Void){}
    //锻炼地点类型
    func resolveWorkoutLocationType(forStartWorkout intent: INStartWorkoutIntent, with completion: (INWorkoutLocationTypeResolutionResult) -> Swift.Void){}
    //开放式
    func resolveIsOpenEnded(forStartWorkout intent: INStartWorkoutIntent, with completion: (INBooleanResolutionResult) -> Swift.Void){}
    
    // MARK: - INPauseWorkoutIntentHandling
    //只有resolveWorkoutName
    
    // MARK: - INResumeWorkoutIntent
    //只有resolveWorkoutName
    
    // MARK: - INCancelWorkoutIntent
    //只有resolveWorkoutName
    
    // MARK: - INEndWorkoutIntentHandling
    //只有resolveWorkoutName
    
    // MARK: - INRequestRideIntent
    //发订单
    func handle(requestRide intent: INRequestRideIntent, completion: (INRequestRideIntentResponse) -> Swift.Void){}

    func confirm(requestRide intent: INRequestRideIntent, completion: (INRequestRideIntentResponse) -> Swift.Void){}
    //接人地点
    func resolvePickupLocation(forRequestRide intent: INRequestRideIntent, with completion: (INPlacemarkResolutionResult) -> Swift.Void){}
    //下车地点
    func resolveDropOffLocation(forRequestRide intent: INRequestRideIntent, with completion: (INPlacemarkResolutionResult) -> Swift.Void){}
    //选项。出租车？专车？
    func resolveRideOptionName(forRequestRide intent: INRequestRideIntent, with completion: (INSpeakableStringResolutionResult) -> Swift.Void){}
    //几人？
    func resolvePartySize(forRequestRide intent: INRequestRideIntent, with completion: (INIntegerResolutionResult) -> Swift.Void){}
    //付款方法
    func resolvePaymentMethodName(forRequestRide intent: INRequestRideIntent, with completion: (INSpeakableStringResolutionResult) -> Swift.Void){}
    //
    func resolveUsesApplePayForPayment(forRequestRide intent: INRequestRideIntent, with completion: (INBooleanResolutionResult) -> Swift.Void){}
    
    // MARK: - INGetRideStatusIntent
    //接单了，询问车到哪了？
    func startSendingUpdates(forGetRideStatus intent: INGetRideStatusIntent, to observer: INGetRideStatusIntentResponseObserver){}
    
    func stopSendingUpdates(forGetRideStatus intent: INGetRideStatusIntent){}

    // MARK: - INListRideOptionsIntent
    //发一组？
    
}

