//
//  Tile.swift
//  iOS9DevSwiftSweeper
//
//  Created by Jason Cheladyn on 7/10/16.
//  Copyright © 2016 Liyicky. All rights reserved.
//

import Foundation

class Tile {
    
    let row : Int
    let column : Int
    
    var isTileDown = false
    var isFlagged = false
    var isAMine = false
    var nearbyMines:Int = 0
    
    init(row:Int, column:Int) {
        self.row = row
        self.column = column
    }
    
}
