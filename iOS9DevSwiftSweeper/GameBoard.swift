//
//  GameBoard.swift
//  iOS9DevSwiftSweeper
//
//  Created by Jason Cheladyn on 7/10/16.
//  Copyright © 2016 Liyicky. All rights reserved.
//

import Foundation

class GameBoard {
    enum difficulty { case easy, medium, hard }
    
    var boardSize_ = 10;
    var totalTiles_ : Int
    var numOfTappedTilesToWin_ : Int?
    var mineRandomizer:UInt32 = 10
    var tiles:[[Tile]] = []
    var mineCount = 0
    
    init(selectedDifficulty: difficulty) {
        totalTiles_ = boardSize_ * boardSize_
        implementDifficulty(selectedDifficulty)
        
        for row in 0 ..< boardSize_ {
            var tilesRow:[Tile] = []
            for col in 0 ..< boardSize_ {
                let tile = Tile(row: row, column: col)
                tilesRow.append(tile)
            }
            
            tiles.append(tilesRow)
        }
        
        resetBoard()
    }
    
    func implementDifficulty(choosenDifficulty: difficulty) {
        switch (choosenDifficulty) {
        case .easy:
            mineRandomizer = 8
            break
        case .medium:
            mineRandomizer = 5
            break
        case .hard:
            mineRandomizer = 3
            break
        }
    }
    
    
    func createRandomMineTiles(tile: Tile) {
        tile.isAMine = ((arc4random()%mineRandomizer) == 0)
        
        if tile.isAMine {
            mineCount += 1
        }
    }
    
    func calculateNearbyMines(currentTile: Tile) {
        let surroundingTiles = getNearbyTiles(currentTile)
        
        var nearbyMines = 0
        
        for nearbyTile in surroundingTiles {
            if nearbyTile.isAMine {
                nearbyMines += 1
            }
        }
        
        currentTile.nearbyMines = nearbyMines
    }
    
    func getNearbyTiles(selectedTile: Tile) -> [Tile] {
        var nearbyTiles:[Tile] = []
        
        let nearbyTileOffsets =
        [(-1,-1), //bottom left corner from selected table
         (0,-1),  //directly below
         (1,-1),  //bottom right corner
         (-1,0),  //directly left
         (1,0),   //directly right
         (-1,1),  //top left corner
         (0,1),   //directly above
         (1,1)]   //top right corner
        
        for (rowOffset,columnOffset) in nearbyTileOffsets {
            let ajacentTile:Tile? = getAjacentTileLocation(selectedTile.row+rowOffset,
                                                           col: selectedTile.column+columnOffset)
            if let validAjacentTile = ajacentTile {
                nearbyTiles.append(validAjacentTile)
            }
        }
        
        return nearbyTiles
    }
    
    func getAjacentTileLocation(row: Int, col: Int) -> Tile? {
        if row >= 0 && row < boardSize_ && col >= 0 && col < boardSize_ {
            return tiles[row][col]
        } else {
            return nil
        }
    }
    
    
    func resetBoard() {
        mineCount = 0
        
        for row in 0 ..< boardSize_ {
            for col in 0 ..< boardSize_ {
                self.createRandomMineTiles(tiles[row][col])
                tiles[row][col].isTileDown = false
            }
        }
        
        numOfTappedTilesToWin_ = totalTiles_ - mineCount
        
        for row in 0 ..< boardSize_ {
            for col in 0 ..< boardSize_ {
                self.calculateNearbyMines(tiles[row][col])
            }
        }
    }
}
