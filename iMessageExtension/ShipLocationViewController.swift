//
//  ShipLocationViewController.swift
//  Battleship
//
//

import UIKit

class ShipLocationViewController: UIViewController {

    @IBOutlet weak var gameBoard: GameBoardView!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var finishedButton: UIButton!
    
    var onLocationSelectionComplete: ((gameState: GameModel, snapshot: UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        
        //选中cell
        gameBoard.onCellSelection = {
            [unowned self]
            cellLocation in
            
            //没超过限额
            // Only alter the cell style if we have ships left to position or we're toggling a cell that currently contains a ship
            guard self.shipsLeftToPosition > 0 ||
                self.gameBoard.selectedCells.contains(cellLocation) else {
                return
            }
            
            self.gameBoard.toggleCellStyle(at: cellLocation)
            self.updateLabels()
        }
    }
    
    //截图
    @IBAction func completedShipLocationSelection(_ sender: AnyObject) {
        let model = GameModel(shipLocations: gameBoard.selectedCells, isComplete: false)
        
        // Clear screen for snapshot (we don't want to give away where we've located our ships!)
        gameBoard.reset()
        
        onLocationSelectionComplete?(gameState: model, snapshot: UIImage.snapshot(from: gameBoard))
    }
}

extension ShipLocationViewController {
    private var shipsLeftToPosition: Int {
        return GameConstants.totalShipCount - self.gameBoard.selectedCells.count
    }
    
    private func updateLabels() {
        remainingLabel.text = "Ships to Place: \(shipsLeftToPosition)"
        finishedButton.isEnabled = shipsLeftToPosition == 0
    }
}
