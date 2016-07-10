//
//  MineTileButton.swift
//  iOS9DevSwiftSweeper
//
//  Created by Jason Cheladyn on 7/10/16.
//  Copyright © 2016 Liyicky. All rights reserved.
//

import UIKit

class MineTileButton : UIButton {
    
    let tileSize:CGFloat
    var tile:Tile
    
    init(tileButton:Tile, size:CGFloat) {
        self.tile = tileButton
        self.tileSize = size
        
        let x = CGFloat(self.tile.column) * tileSize
        let y = CGFloat(self.tile.row) * tileSize
        let tileBoundingFrame = CGRectMake(x, y, tileSize, tileSize)
        
        super.init(frame: tileBoundingFrame);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTileLabelText() -> String {
        if !self.tile.isAMine {
            if self.tile.nearbyMines == 0 {
                return "0"
            } else {
                return "\(self.tile.nearbyMines)"
            }
        }
        return "💣"
    }
}