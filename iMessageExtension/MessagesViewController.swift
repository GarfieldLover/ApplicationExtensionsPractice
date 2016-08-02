//
//  MessagesViewController.swift
//  MessagesExtension
//
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    //lifecycle
    //激活
    override func willBecomeActive(with conversation: MSConversation) {
        //处理当前显示v
        configureChildViewController(for: presentationStyle, with: conversation)
    }
    
    // self.requestPresentationStyle(.expanded)
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = self.activeConversation else { return }
        configureChildViewController(for: presentationStyle, with: conversation)
    }
}

extension MessagesViewController {
    private func configureChildViewController(for presentationStyle: MSMessagesAppPresentationStyle,
                                              with conversation: MSConversation) {
        // Remove any existing child view controllers
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Now let's create our new one
        let childViewController: UIViewController
        
        //紧凑模式 ，引导内容
        //展开模式，详细内容
        switch presentationStyle {
        case .compact:
            childViewController = createGameStartViewController()
        case .expanded:
            //回复
            if let message = conversation.selectedMessage,
                let url = message.url {
                //解析
                let model = GameModel(from: url)
                childViewController = createShipDestroyViewController(with: conversation, model: model)
            }
            else {
                //发送
                childViewController = createShipLocationViewController(with: conversation)
            }
        }
        
        // Add controller
        addChildViewController(childViewController)
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
        
        childViewController.didMove(toParentViewController: self)
    }
    
    private func createShipLocationViewController(with conversation: MSConversation) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ShipLocationViewController") as? ShipLocationViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        //发送
        controller.onLocationSelectionComplete = {
            [unowned self]
            model, snapshot in
            //UUID。
            let session = MSSession()
            let caption = "$\(conversation.localParticipantIdentifier) placed their ships! Can you find them?"
            
            self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            
            self.dismiss()
        }
        
        return controller
    }
    
    private func createShipDestroyViewController(with conversation: MSConversation, model: GameModel) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ShipDestroyViewController") as? ShipDestroyViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        //扫雷完成并发送
        controller.model = model
        controller.onGameCompletion = {
            [unowned self]
            model, playerWon, snapshot in
            
            if let message = conversation.selectedMessage,
                let session = message.session {
                let player = "$\(conversation.localParticipantIdentifier)"
                let caption = playerWon ? "\(player) destroyed all the ships!" : "\(player) lost!"
                
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            }
            
            self.dismiss()
        }
        
        return controller
    }
    
    private func createGameStartViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "GameStartViewController") as? GameStartViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        //展开
        controller.onButtonTap = {
            [unowned self] in
            self.requestPresentationStyle(.expanded)
        }
        
        return controller
    }
}

//创建MSMessage 并发送
extension MessagesViewController {
    /// Constructs a message and inserts it into the conversation
    func insertMessageWith(caption: String,
                           _ model: GameModel,
                           _ session: MSSession,
                           _ image: UIImage,
                           in conversation: MSConversation) {
        let message = MSMessage(session: session)
        let template = MSMessageTemplateLayout()
        //message layout内容
        template.image = image
//        template.imageTitle = "截图"

        template.caption = caption
        message.layout = template
        //编码，再解码
        message.url = model.encode()
        
        // Now we've constructed the message, insert it into the conversation
        conversation.insert(message)
    }
}
