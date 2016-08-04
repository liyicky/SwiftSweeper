//
//  GameScene.swift
//  iOS9DevSwiftSweeper
//
//  Created by Jason Cheladyn on 7/7/16.
//  Copyright (c) 2016 Liyicky. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    enum gameState {
        case Instructions, DifficultyMenu, MineTap, FlagPlanting, GameOver, WIN
    }
    
    enum OnOffSwitch {
        case Off, On
        mutating func toggle() {
            switch self {
            case Off:
                self = On
            case On:
                self = Off
            }
        }
    }
    
    var currentGameState_ : gameState!
    var currentDifficulty_ : GameBoard.difficulty?
    
    weak var stageView_ : SKView!
    var backDropView_ : UIView!
    var HUD : SKNode!
    var mineBoard_ : GameBoard!
    
    var tileButtons_ : [MineTileButton] = []
    
    //labels
    let timerLabel_ = SKLabelNode(fontNamed: "DamascusBold")
    let statusLabel_ = SKLabelNode(fontNamed: "Georgia-BoldItalic")
    let movesLabel_ = SKLabelNode(fontNamed: "Chalkduster")
    
    let flagButton_ = SKSpriteNode(imageNamed: "flagButton.png")
    var flagSwitch_ = OnOffSwitch.Off
    let flagStatusLabel_ = SKLabelNode(fontNamed: "Chalkduster")
    
    var playerTimer_ : NSTimer?
    var timerStopped_ = true
    
    let instructionsSprite_ = SKSpriteNode(imageNamed: "SwiftSweeperInstructions")
    
    var didFirstGameLoad_ = false
    
    var difficultySprite_ : SKSpriteNode?
    let difficultyButton_ = UIButton(type: UIButtonType.System)
    let easyButton_ = UIButton(type: UIButtonType.System)
    let mediumButton_ = UIButton(type: UIButtonType.System)
    let hardButton_ = UIButton(type: UIButtonType.System)
    
    var bestTimeEasy_ : Int?, bestTimeMedium_: Int?, bestTimeHard_ : Int?
    var gotNewTimeRecord_ : Bool = false
    
    
    //MARK: Getters/Setters
    //*******************************************************************
    
    var playerTime_ : Int = 0 {
        didSet {
            self.timerLabel_.text = "Time: \(playerTime_)"
            
            if playerTime_ >= 9999{
                playerTime_ + 9999
            }
        }
    }
    
    var moves_ : Int = 0 {
        didSet {
            self.movesLabel_.text = "Moves: \(moves_)"
            
            if moves_ == 1 && currentGameState_ == .MineTap {
                beginTimer()
            }
            
            if (moves_ >= mineBoard_.numOfTappedTilesToWin_ && currentGameState_ != .GameOver) {
                killTimer()
                winSequence()
            }
        }
    }
    
    //MARK: Main Game Loop Entry Point, didMoveToView
    //*******************************************************************
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.whiteColor()
        stageView_ = view
        loadInstructions()
    }
    
    func loadHUD() {
        HUD = SKNode()
        
        loadTitleText()
        loadFlagButton()
        
        self.addChild(HUD)
    }
    
    //MARK: Instructions
    //*******************************************************************
    
    func loadInstructions() {
        instructionsSprite_.zPosition = 100
        instructionsSprite_.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height/2)
        instructionsSprite_.setScale(0.45)
        instructionsSprite_.alpha = 0.0
        
        self.addChild(instructionsSprite_)
        
        instructionsSprite_.runAction(SKAction.fadeInWithDuration(1.0))
        currentGameState_ = .Instructions
    }
    
    func removeInstructions() {
        let transistionTime = 0.6
        instructionsSprite_.runAction(SKAction.sequence(
            [SKAction.fadeOutWithDuration(transistionTime),
                SKAction.runBlock(deleteInstructions)]
            ))
        NSTimer.scheduledTimerWithTimeInterval(transistionTime, target: self, selector: Selector("chooseDifficultyMenu"), userInfo: nil, repeats: false)
    }
    
    func deleteInstructions() {
        instructionsSprite_.removeFromParent()
    }
    
    //MARK: Menus
    //*******************************************************************
    
    func chooseDifficultyMenu() {
        self.currentGameState_ = .DifficultyMenu
        
        var yOffset : CGFloat
        
        if didFirstGameLoad_ {
            yOffset = 40
        } else {
            yOffset = 0
        }
        
        backDropView_ = UIView()
        backDropView_.backgroundColor = UIColor.blackColor()
        backDropView_.alpha = 0.4
        
        if didFirstGameLoad_ {
            stageView_.addSubview(backDropView_)
        }
        
        let image = UIImage(named: "chooseDifficulty")
        
        difficultyButton_.frame = CGRectMake(15, 40, image!.size.width * 0.58, image!.size.height * 0.6)
        
        //Bug: Doesn't show after stage loads
        difficultySprite_ = SKSpriteNode(imageNamed: "chooseDifficulty")
        difficultySprite_?.position = CGPointMake(self.frame.width/2, self.frame.height*0.9)
        difficultySprite_?.zPosition = 100
        self.addChild(difficultySprite_!)
        
        easyButton_.frame = CGRectMake(15, 120-yOffset, image!.size.width * 0.58, image!.size.height * 0.6)
        easyButton_.addTarget(self, action: "easyDifficultySelected", forControlEvents:.TouchUpInside)
        easyButton_.setTitle("EASY", forState: .Normal)
        easyButton_.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        easyButton_.backgroundColor = UIColor.greenColor()
        
        mediumButton_.frame = CGRectMake(15, 220-yOffset, image!.size.width * 0.58, image!.size.height * 0.6)
        mediumButton_.addTarget(self, action: "mediumDifficultySelected", forControlEvents:.TouchUpInside)
        mediumButton_.setTitle("MEDIUM", forState: .Normal)
        mediumButton_.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mediumButton_.backgroundColor = UIColor.orangeColor()
        
        hardButton_.frame = CGRectMake(15, 320-yOffset, image!.size.width * 0.58, image!.size.height * 0.6)
        hardButton_.addTarget(self, action: "hardDifficultySelected", forControlEvents:.TouchUpInside)
        hardButton_.setTitle("HARD", forState: .Normal)
        hardButton_.setTitleColor(UIColor.blackColor(), forState: .Normal)
        hardButton_.backgroundColor = UIColor.redColor()
        
        
        stageView_.addSubview(difficultyButton_)
        stageView_.addSubview(easyButton_)
        stageView_.addSubview(mediumButton_)
        stageView_.addSubview(hardButton_)
    }
    
    func loadTitleText() {
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "~ Swift Sweeper ~"
        titleLabel.fontSize = 45
        titleLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height*0.25)
        
        HUD.addChild(titleLabel)
        
        statusLabel_.text = ""
        statusLabel_.fontSize = 40
        statusLabel_.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height*0.15)
        
        HUD.addChild(statusLabel_)
        
        flagStatusLabel_.text = ""
        flagStatusLabel_.zPosition = 50
        flagStatusLabel_.fontSize = 30
        flagStatusLabel_.position = CGPoint(x:self.frame.width*0.40, y:self.frame.height*0.17)
        
        HUD.addChild(flagStatusLabel_)
        
        //text that tells the player how many moves they've made
        movesLabel_.zPosition = 50
        movesLabel_.fontSize = 36
        movesLabel_.position = CGPoint(x:self.frame.width*0.37, y:self.frame.height*0.05)
        movesLabel_.text = "Moves: \(moves_)"
        
        
        HUD.addChild(movesLabel_)
        
        //player timer
        //text that tells the player their time playing
        timerLabel_.zPosition = 50
        timerLabel_.fontSize = movesLabel_.fontSize
        timerLabel_.position = CGPoint(x:self.frame.width*0.60, y:movesLabel_.position.y)
        timerLabel_.text = "Time: \(playerTime_)"
        
        HUD.addChild(timerLabel_)
    }
    
    //MARK: Difficulty Logic
    //*******************************************************************
    
    func easyDifficultySelected() {
        currentDifficulty_ = .easy
        removeDifficultyMenu()
    }
    
    func mediumDifficultySelected(){
        currentDifficulty_ = .medium
        removeDifficultyMenu()
    }
    
    func hardDifficultySelected(){
        currentDifficulty_ = .hard
        removeDifficultyMenu()
    }
    
    func removeDifficultyMenu() {
        difficultySprite_!.removeFromParent()
        difficultyButton_.removeFromSuperview()
        easyButton_.removeFromSuperview()
        mediumButton_.removeFromSuperview()
        hardButton_.removeFromSuperview()
        
        if didFirstGameLoad_ {
            backDropView_.removeFromSuperview()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("delayedGameStart"), userInfo: nil, repeats: false)
    }
    
    //MARK: Timers
    //*******************************************************************
    
    func beginTimer() {
        playerTimer_ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("incrementTimer"), userInfo: nil, repeats: true)
        timerStopped_ = false;
    }
    
    func incrementTimer() {
        playerTime_ += 1
    }
    
    //MARK: Start Game Logic
    //*******************************************************************
    
    func delayedGameStart() {
        if !didFirstGameLoad_ {
            beginGame()
        } else {
            resetBoard()
        }
    }
    
    func beginGame() {
        didFirstGameLoad_ = true
        
        loadHUD()
        initializeBoard()
        self.backgroundColor = UIColor.lightGrayColor()
        
        currentGameState_ = .MineTap
    }
    
    func initializeBoard() {
        mineBoard_ = GameBoard(selectedDifficulty: currentDifficulty_!)
        
        beginTimer()
        
        for row in 0 ..< mineBoard_.boardSize_ {
            for col in 0 ..< mineBoard_.boardSize_ {
                let singleTile = mineBoard_.tiles[row][col]
                let tileSize : CGFloat = self.stageView_.frame.width / CGFloat(mineBoard_.boardSize_)
                let tileButton = MineTileButton(tileButton: singleTile, size: tileSize)
                
                tileButton.setTitle("◻", forState: .Normal)
                tileButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                tileButton.backgroundColor = UIColor.whiteColor()
                tileButton.addTarget(self, action: "tileButtonTapped:", forControlEvents: .TouchUpInside)
                
                self.stageView_.addSubview(tileButton)
                self.tileButtons_.append(tileButton)
            }
        }
    }
    
    func loadFlagButton() {
        flagButton_.position = CGPoint(x: self.frame.width*0.70, y: self.frame.height*0.17)
        flagButton_.zPosition = 50
        flagButton_.setScale(0.2)
        flagButton_.runAction(SKAction.fadeInWithDuration(0.6))
        
        HUD.addChild(flagButton_)
    }
    
    //MARK: Touch / Swipe Controls
    //*******************************************************************
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if CGRectContainsPoint(flagButton_.frame, touch.locationInNode(self)) {
                flagButtonPressed()
            }
            
            if CGRectContainsPoint(instructionsSprite_.frame, touch.locationInNode(self)) && currentGameState_ == .Instructions {
                removeInstructions()
            }
        }
    }
    
    func tileButtonTapped(sender: MineTileButton) {
        if (currentGameState_ != .MineTap && currentGameState_ != .FlagPlanting) {
            return
        }
        
        if (!sender.tile.isTileDown && currentGameState_ == .MineTap) {
            sender.tile.isTileDown = true
            sender.setTitle("\(sender.getTileLabelText())", forState: .Normal)
            
            if sender.tile.isAMine {
                self.mineHit()
            }
            
            moves_ += 1
        }
        
        else if (!sender.tile.isTileDown && currentGameState_ == .FlagPlanting) {
            self.flagPlant(sender)
        }
    }
    
    func flagButtonPressed() {
        if (currentGameState_ != .MineTap && currentGameState_ != .FlagPlanting) {
            return
        }
        
        if flagSwitch_ == .Off {
            currentGameState_ = .FlagPlanting
            flagStatusLabel_.text = "Flag Mode ON"
        } else {
            currentGameState_ = .MineTap
            flagStatusLabel_.text = ""
        }
        
        flagSwitch_.toggle()
    }
    
    //MARK: Game Event Sequences
    //*******************************************************************
    
    func flagPlant(tileToFlag: MineTileButton) {
        if !tileToFlag.isFlagged {
            tileToFlag.setTitle("🚩", forState: .Normal)
            tileToFlag.isFlagged = true
            self.runAction(SKAction.playSoundFileNamed("flagPlant.wav", waitForCompletion: false))
        } else {
            tileToFlag.setTitle("◻", forState: .Normal)
            tileToFlag.isFlagged = true
            self.runAction(SKAction.playSoundFileNamed("flagRemove.wav", waitForCompletion: false))
        }
    }
    
    func mineHit() {
        self.runAction(SKAction.playSoundFileNamed("mineExplosion.wav", waitForCompletion: false))
        
        statusLabel_.text = "You Lose! 😵"
        flagStatusLabel_.text = ""
        
        killTimer()
        gameOverSequence()
    }
    
    func killTimer() {
        if !timerStopped_ {
            timerStopped_ = true
            playerTimer_!.invalidate()
            playerTimer_ = nil
        }
    }
    
    func gameOverSequence() {
        currentGameState_ = .GameOver
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("newGamePrompt"), userInfo: nil, repeats: false)
    }
    
    func winSequence() {
        statusLabel_.text = "You Win! 😀"
        currentGameState_ = .WIN
        self.runAction(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
        
        savePlayersTime()
        
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("newGamePrompt"), userInfo: nil, repeats: false)
    }
    
    func resetBoard() {
        mineBoard_.implementDifficulty(currentDifficulty_!)
        mineBoard_.resetBoard()
        
        moves_ = 0
        playerTime_ = 0
        gotNewTimeRecord_ = false
        statusLabel_.text = ""
        flagStatusLabel_.text = ""
        
        for tileButton in self.tileButtons_ {
            tileButton.setTitle("◻", forState: .Normal)
            tileButton.backgroundColor = UIColor.whiteColor()
            tileButton.isFlagged = false
        }
        
        currentGameState_ = .MineTap
    }
    
    func newGamePrompt() {
        loadBestTimes()
        
        let bestScoreString = getBestScoreString()
        
        var newRecordText : String
        if (gotNewTimeRecord_) {
            newRecordText = "\n\n NEW RECORD TIME! 🏆"
        } else {
            newRecordText = ""
        }
    
        let alertController : UIAlertController
        let messageString : String
    
        if (currentGameState_ == .WIN) {
            messageString = "You isolated all of the mines! \(bestScoreString) \(newRecordText)"
            alertController = UIAlertController(title: "You Win! 😊", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "New Game ↩", style: .Default) {
                (action) in self.resetBoard()
            })
        } else {
            messageString = "Shucks, you landed on a mine \(bestScoreString) \(newRecordText)"
            alertController = UIAlertController(title: "You Lose! 😵", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry ↩", style: .Default) {
                (action) in self.resetBoard()
            })
        }
    
        alertController.addAction(UIAlertAction(title: "Change Difficulty 🎮", style:.Default){
            (action) in self.chooseDifficultyMenu()
        })
    
        self.view!.window!.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    func getBestScoreString() -> (String) {
        var easyTimeString : String
        var mediumTimeString : String
        var hardTimeString : String
        
        if bestTimeEasy_ != 0 {
            easyTimeString = "\(bestTimeEasy_!)"
        } else {
            easyTimeString = "No Best Time Yet"
        }
        
        if bestTimeMedium_ != 0 {
            mediumTimeString = "\(bestTimeMedium_!) seconds"
        } else {
            mediumTimeString = "No Best Time Yet"
        }
        
        if bestTimeHard_ != 0 {
            hardTimeString = "\(bestTimeHard_!) seconds"
        } else {
            hardTimeString = "No Best Time Yet"
        }
        
        return "\n\n Best Time 🕑 \n\n Easy:    \(easyTimeString) \n\n Medium: \(mediumTimeString) \n\n Hard:    \(hardTimeString)"
    }
    

    func savePlayersTime() {
        let bestTime = loadPlayersTime(currentDifficulty_!)
        
        if (bestTime == 0 || bestTime > playerTime_) {
            gotNewTimeRecord_ = true
            
            var savedTimeKey : String
            
            switch currentDifficulty_! {
            case .easy:
                savedTimeKey = "bestTime_Easy"
                break
            case .medium:
                savedTimeKey = "bestTime_Medium"
                break
            case .hard:
                savedTimeKey = "bestTime_Hard"
                break
                
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(playerTime_, forKey: savedTimeKey)
        }
    }
        

    func loadPlayersTime(difficulty: GameBoard.difficulty) -> (Int)  {
        var loadedTimeKey : String
        
        switch difficulty {
        case .easy:
            loadedTimeKey = "bestTime_Easy"
            break
        case .medium:
            loadedTimeKey = "bestTime_Medium"
            break
        case .hard:
            loadedTimeKey = "bestTime_Hard"
            break
        }
        
        return NSUserDefaults.standardUserDefaults().integerForKey(loadedTimeKey)
    }
    
    func loadBestTimes(){
        bestTimeEasy_   = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Easy")
        bestTimeMedium_ = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Medium")
        bestTimeHard_   = NSUserDefaults.standardUserDefaults().integerForKey("bestTime_Hard")
        
    }

    
    //MARK: Game Loop update()
    //*******************************************************************

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
