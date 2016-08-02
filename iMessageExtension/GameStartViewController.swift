//
//  GameStartViewController.swift
//  Battleship
//
//

import UIKit

class GameStartViewController: UIViewController {
    
    var onButtonTap: ((Void) -> Void)?
    
    @IBAction func startGame(_ sender: AnyObject) {
        onButtonTap?()
    }
}
