//
//  KeyboardViewController.swift
//  CustomKeyboardExtension
//
//  Created by zhangke on 16/8/3.
//
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var numbersRow1View: UIView!
    @IBOutlet var numbersRow2View: UIView!
    @IBOutlet var symbolsRow1View: UIView!
    @IBOutlet var symbolsRow2View: UIView!
    @IBOutlet var numbersSymbolsRow3View: UIView!
    
    @IBOutlet var switchModeRow3Button: UIButton!
    @IBOutlet var switchModeRow4Button: UIButton!
    @IBOutlet var shiftButton: UIButton!
    @IBOutlet var spaceButton: UIButton!
    @IBOutlet var letterButtonsArray: NSArray!

    var _shiftStatus: Int = 0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.white()
//        } else {
//            textColor = UIColor.black()
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    
    func initializeKeyboard() -> Void {
        _shiftStatus = 1
        
        let shiftDoubleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(shiftKeyDoubleTapped))
        let shiftTripleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(shiftKeyPressed))

        
        shiftDoubleTap.numberOfTapsRequired = 2
        shiftDoubleTap.numberOfTapsRequired = 3
        
        shiftButton.addGestureRecognizer(shiftDoubleTap)
        shiftButton.addGestureRecognizer(shiftTripleTap)

    }
    
    
    
    @IBAction func globeKeyPressed(sender: UIButton) -> Void {
        self.advanceToNextInputMode()
    }
    
    @IBAction func keyPressed(sender: UIButton) -> Void {
        self.textDocumentProxy.insertText((sender.titleLabel?.text)!)
        
        if _shiftStatus == 1 {
            self.shiftKeyPressed(sender: shiftButton)
        }
    }
    
    @IBAction func backspaceKeyPressed(sender: UIButton) -> Void {
        self.textDocumentProxy.deleteBackward()
    }
    
    @IBAction func spaceKeyPressed(sender: UIButton) -> Void {
        self.textDocumentProxy.insertText(" ")
    }

    @IBAction func shiftKeyDoubleTapped(sender: UIButton) -> Void {
        _shiftStatus = 2;
        
        self.shiftKeys()
    }
    
    @IBAction func shiftKeyPressed(sender: UIButton) -> Void {
        _shiftStatus = _shiftStatus > 0 ? 0 : 1;
        
        self.shiftKeys()
    }
    
    @IBAction func returnKeyPressed(sender: UIButton) -> Void {
        self.textDocumentProxy.insertText("\n")
    }
    
    func shiftKeys() -> Void {
        
        if _shiftStatus == 0 {
            for button in letterButtonsArray {
                let letterButton: UIButton = button as! UIButton
                letterButton.setTitle(letterButton.titleLabel?.text?.lowercased(), for: UIControlState.normal)
            }
        } else {
            for button in letterButtonsArray {
                let letterButton: UIButton = button as! UIButton
                letterButton.setTitle(letterButton.titleLabel?.text?.uppercased(), for: UIControlState.normal)
            }
        }
        
        let shiftButtonImageName: String = String.init(format: "shift_%i.png", _shiftStatus)
        let shiftButtonImage: UIImage = UIImage.init(named: shiftButtonImageName)!
        shiftButton.setImage(shiftButtonImage, for: UIControlState.normal)
        
        let shiftButtonHLImageName: String = String.init(format: "shift_%iHL.png", _shiftStatus)
        let shiftButtonHLImage: UIImage = UIImage.init(named: shiftButtonHLImageName)!
        shiftButton.setImage(shiftButtonHLImage, for: UIControlState.highlighted)
    }
    
    
    @IBAction func switchKeyboardMode(sender: UIButton) -> Void {
        numbersRow1View.isHidden = true
        numbersRow2View.isHidden = true
        symbolsRow1View.isHidden = true
        symbolsRow2View.isHidden = true
        numbersSymbolsRow3View.isHidden = true
        
        switch sender.tag {
        case 1:
            numbersRow1View.isHidden = false
            numbersRow2View.isHidden = false
            numbersSymbolsRow3View.isHidden = false
            
            switchModeRow3Button.tag = 2
            switchModeRow3Button.setImage(UIImage.init(named: "symbols.png"), for: UIControlState.normal)
            switchModeRow3Button.setImage(UIImage.init(named: "symbolsHL.png"), for: UIControlState.highlighted)
            
            switchModeRow4Button.tag = 0
            switchModeRow4Button.setImage(UIImage.init(named: "abc.png"), for: UIControlState.normal)
            switchModeRow4Button.setImage(UIImage.init(named: "abcHL.png"), for: UIControlState.highlighted)
            
            break
            
        case 2:
            symbolsRow1View.isHidden = true
            symbolsRow2View.isHidden = true
            numbersSymbolsRow3View.isHidden = true
            
            switchModeRow3Button.tag = 0
            switchModeRow3Button.setImage(UIImage.init(named: "numbers.png"), for: UIControlState.normal)
            switchModeRow3Button.setImage(UIImage.init(named: "numbersHL.png"), for: UIControlState.highlighted)
            break
            
        default:
            switchModeRow4Button.tag = 1
            switchModeRow4Button.setImage(UIImage.init(named: "numbers.png"), for: UIControlState.normal)
            switchModeRow4Button.setImage(UIImage.init(named: "numbersHL.png"), for: UIControlState.highlighted)
            
            break

        }
        
    }
    
}
