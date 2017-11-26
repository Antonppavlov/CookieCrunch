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
    
    var level:Level?
    
    let TitleWith:CGFloat = 32.0
    let TitleHeight:CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLater = SKNode()
    
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
        
        let layerPosition = CGPoint(x: -TitleWith*CGFloat(NumColumns)/2, y: -TitleHeight*CGFloat(NumRows)/2)
      
        cookiesLayer.position = layerPosition
        tilesLater.position = layerPosition
        
        gameLayer.addChild(tilesLater)
        gameLayer.addChild(cookiesLayer)
        
        
    }
    
    func addSprite(cookies:Set<Cookie>){
        for cookie in cookies{

            let sptiteTile = SKSpriteNode(imageNamed: "Tile")
            sptiteTile.position = poinFor(column:cookie.column , row:cookie.row)
            sptiteTile.size = CGSize(width: TitleWith, height: TitleHeight)
            sptiteTile.position = poinFor(column:cookie.column , row:cookie.row)
            tilesLater.addChild(sptiteTile)
            
            
            let imageNamed = cookie.cookieType.spriteName
            let spriteCookie = SKSpriteNode(imageNamed: imageNamed)
            spriteCookie.size = CGSize(width: TitleWith, height: TitleHeight)
            spriteCookie.position = poinFor(column:cookie.column , row:cookie.row)
            cookiesLayer.addChild(spriteCookie)
            cookie.sprite = spriteCookie
            

        }
    }
    
    func poinFor(column:Int , row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TitleWith+TitleWith/2,
            y: CGFloat(row)*TitleHeight+TitleHeight/2
        )
    }
    
    
}

