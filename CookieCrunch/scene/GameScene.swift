//
//  GameScene.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 25.11.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {
    
    var level:Level!
    
    private var swipeFromColumn:Int?
    private var swipeFromRow:Int?
    

    let TileWidth:CGFloat = 32.0
    let TileHeight:CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    var swapHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //система кординат. значит что центральная точка по центру
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //установка бекграунда
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        
        addChild(background)
        addChild(gameLayer)
        
       
        let layerPosition = CGPoint(x: -TileWidth*CGFloat(NumColumns)/2, y: -TileHeight*CGFloat(NumRows)/2)

        tilesLayer.position = layerPosition
      
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cropLayer)
        
        
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
        cookiesLayer.position = layerPosition
        cropLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        background.zPosition=100
        gameLayer.zPosition=200
        cropLayer.zPosition=300
        cookiesLayer.zPosition=400
        
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
      
    }
    
    func showSelectionIndicatiorForCookies(_ cookie:Cookie){
        if(selectionSprite.parent != nil){
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            
            selectionSprite.alpha = 1.0
            selectionSprite.run(SKAction.setTexture(texture))
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.addChild(selectionSprite)
        }
    }
    
    func hideSelectionIndicatiorForCookies(){
        selectionSprite.run(SKAction.sequence([SKAction.fadeOut(withDuration: TimeInterval(0.3)),SKAction.removeFromParent()]))
    }
    
    func animateGameOver( comletion: @escaping() -> ()){
        let action = SKAction.move(by: CGVector(dx:0, dy:-size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: comletion)
    }
    
    func animateBeginGame( comletion: @escaping() -> ()){
        gameLayer.isPaused = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx:0, dy:-size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: comletion)
    }
    
    
    
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        for row in 0 ... NumRows {
            for column in 0 ... NumColumns {
                let topLeft = (column > 0) && (row < NumRows) && level.tileAt(column: column-1, row: row) != nil
                let bottomLeft = (column > 0) && (row > 0) && level.tileAt(column: column-1, row: row-1) != nil
                let topRight = (column < NumColumns) && (row < NumRows) && level.tileAt(column: column, row: row) != nil
                let bottomRight = (column < NumColumns) && (row > 0) && level.tileAt(column: column, row: row-1) != nil
                
                var value = Int(topLeft.hashValue)
                value |= Int(topRight.hashValue) << 1
                value |= Int(bottomLeft.hashValue) << 2
                value |= Int(bottomRight.hashValue) << 3
                
                if value != 0 && value != 6 && value != 9 {
                    let name = String(format: "Tile_%ld", value)
                    let tileNode = SKSpriteNode(imageNamed: name)
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    var point = pointFor(column: column, row: row)
                    point.x -= TileWidth/2
                    point.y -= TileHeight/2
                    tileNode.position = point
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addSprites(for cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(SKAction.sequence([SKAction.wait(forDuration: 0.25, withRange: 0.5), SKAction.group([SKAction.fadeIn(withDuration: 0.25), SKAction.scale(to: 1.0, duration: 0.25)])]))
        }
    }
    
    func removeAllCookiesSprite(){
        maskLayer.removeAllChildren()
        tilesLayer.removeAllChildren()
        cookiesLayer.removeAllChildren()
    }
    
    func pointFor(column:Int , row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth+TileWidth/2,
            y: CGFloat(row)*TileHeight+TileHeight/2
        )
    }
    
    func convertPint(point:CGPoint)->(success:Bool,column:Int,row:Int) {
        if(point.x >= 0 && point.x <= CGFloat(NumColumns)*TileWidth
            && point.y >= 0 && point.y <= CGFloat(NumRows)*TileHeight){
            return (true, Int(point.x / TileWidth) , Int(point.y / TileHeight))
        }else{
            return (false,0,0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{ return }
        
        let location = touch.location(in: cookiesLayer)
        
        let (success,column,row) = convertPint(point: location)
        
        if(success){
            if let cookie = level?.cookieAt(column: column, row: row){
                showSelectionIndicatiorForCookies(cookie)
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else {return}
        guard swipeFromRow != nil else {return}
        guard let touch = touches.first else{ return }
        
        let location = touch.location(in: cookiesLayer)
        
        let (success,column,row) = convertPint(point: location)
        
        if(success){
            var horizontalDelta = 0
            var verticalDelta = 0
            
            if(column < swipeFromColumn!){
                horizontalDelta = -1
            }else if(column > swipeFromColumn!){
                horizontalDelta = 1
            }else if(row < swipeFromRow!){
                verticalDelta = -1
            }else if(row > swipeFromRow!){
                verticalDelta = 1
            }
            
            if(horizontalDelta != 0 || verticalDelta != 0){
                trySwap(horizontalDelta:horizontalDelta,verticalDelta:verticalDelta)
                hideSelectionIndicatiorForCookies()
                swipeFromColumn = nil
                swipeFromRow = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func trySwap(horizontalDelta:Int,verticalDelta:Int){
        let swipeToColumn = swipeFromColumn! + horizontalDelta
        let swipeToRow = swipeFromRow! + verticalDelta
        
        guard swipeToColumn >= 0 && swipeToColumn <= NumColumns else {return}
        guard swipeToRow >= 0 && swipeToRow <= NumRows else {return}
        
        if let swipeToCookies = level?.cookieAt(column: swipeToColumn, row: swipeToRow), let swipeFromCookies = level?.cookieAt(column:swipeFromColumn!, row: swipeFromRow!){
            
            if let handel = swapHandler {
                let swap = Swap(swipeFrom: swipeFromCookies, swipeTo: swipeToCookies)
                handel(swap)
                
            }
        }
    }
    
    func animateSwape(_ swap:Swap, comletion: @escaping() -> ()){
        let spriteFromCookies = swap.swipeFromCookies.sprite!
        let spriteToCookies = swap.swipeToCookies.sprite!
        
        spriteFromCookies.zPosition = 100
        spriteToCookies.zPosition = 90
        
        let duration:TimeInterval = 0.3
        
        let moveFrom = SKAction.move(to: spriteToCookies.position, duration: duration)
        moveFrom.timingMode = .easeOut
        spriteFromCookies.run(moveFrom, completion:comletion)
        
        let moveTo = SKAction.move(to:spriteFromCookies.position, duration: duration)
        moveTo.timingMode = .easeOut
        spriteToCookies.run(moveTo)
        
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap:Swap, comletion: @escaping() -> ()){
        let spriteFromCookies = swap.swipeFromCookies.sprite!
        let spriteToCookies = swap.swipeToCookies.sprite!
        
        spriteFromCookies.zPosition = 100
        spriteToCookies.zPosition = 90
        
        let duration:TimeInterval = 0.2
        
        let moveFrom = SKAction.move(to: spriteToCookies.position, duration: duration)
        moveFrom.timingMode = .easeOut
        
        let moveTo = SKAction.move(to:spriteFromCookies.position, duration: duration)
        moveTo.timingMode = .easeOut
        
        spriteFromCookies.run(SKAction.sequence([moveFrom,moveTo]));
        spriteToCookies.run(SKAction.sequence([moveTo,moveFrom]));
        
        
        run(invalidSwapSound, completion: comletion)
    }
    
    //анимация удаления печенек
    func animateMatchedCookies(_ chains:Set<Chain>, comletion: @escaping() -> ()){
        for chain in chains{
            
            animateRemoveMathes(chain)
            
            for cookie in chain.cookies{
                if let sprite = cookie.sprite{
                    if sprite.action(forKey: "removing") == nil{
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        
                        sprite.run(SKAction.sequence([scaleAction,SKAction.removeFromParent()]), withKey: "removing")
                        
                    }
                }
            }
        }
        
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: comletion)
    }
    
    //анимация отображения очков с удаленных печенек
    func animateRemoveMathes(_ chain: Chain){
        let cookieFirst =  chain.cookies.first!
        let cookieLast =  chain.cookies.last!
        
        let positionCookieFirst = pointFor(column: cookieFirst.column, row: cookieFirst.row)
        let positionCookieLast = pointFor(column: cookieLast.column, row: cookieLast.row)
        
        let positionScore = CGPoint(x: (positionCookieFirst.x + positionCookieLast.x)/2, y: (positionCookieFirst.y + positionCookieLast.y)/2)
        
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = positionScore
        scoreLabel.zPosition=300
        cookiesLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx:0,dy:3), duration: 0.7)
        moveAction.timingMode = .easeOut
        
        scoreLabel.run(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
    }
    
     //анимация падения печенек
    func animateFallingCookies(columns: [[Cookie]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            for (idx, cookie) in array.enumerated() {
                let newPosition = pointFor(column: cookie.column, row: cookie.row)
                
                let delay = 0.05 + 0.15 * TimeInterval(idx)
                
                let sprite = cookie.sprite!
                
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.05)
                
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([SKAction.wait(forDuration: delay), SKAction.group([moveAction, fallingCookieSound])]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    //анимация последовательного заполнения печенек
    func animateNewCookies(arrayColumn:[[Cookie]], comletion: @escaping() -> ()){
        var longestDuration:TimeInterval = 0
        
        for arrayRow in arrayColumn{
            let startRow = arrayRow[0].row + 1
            for(index, cookie) in arrayRow.enumerated(){
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointFor(column: cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                
                let delay = 0.1 + 0.2 * TimeInterval(arrayRow.count - index - 1)
                
                let duration = TimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration +  delay)
                
                let newPosition = pointFor(column: cookie.column, row: cookie.row)
                
                let moveAction = SKAction.move(to: newPosition,duration:duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                
                sprite.run(
                    SKAction.sequence(
                        [SKAction.wait(forDuration: delay),
                         SKAction.group(
                            [SKAction.fadeIn(withDuration: 0.05),
                             moveAction,
                             addCookieSound])]))
            }
        }
        run(SKAction.wait(forDuration: longestDuration), completion: comletion)
        
    }
    

    
}

