//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 25.11.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene:GameScene!
    var level:Level!
    
    var moves = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            view.isMultipleTouchEnabled = false
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            self.scene = GameScene(size: view.bounds.size)
            self.scene.scaleMode = .aspectFit
            
            self.level = Level(fileName: "Level_0")
            self.scene.level = level
            
            self.scene.swapHandler = hangleSwape(_:)
            
            view.presentScene(scene)
            
           
        }
        
        
        beginGame()
    }
    
    func hangleSwape(_ swap: Swap){
        self.level.detectedPossibleSwaps()
        view.isUserInteractionEnabled = false
        
        if level.isPosibleSwap(swap: swap){
            decrementMoves()
            level.performSwap(swap)
            scene.animateSwape(swap, comletion: {
                self.handeRemoveMathes()
            })
        }else{
            scene.animateInvalidSwap(swap, comletion: {
                self.view.isUserInteractionEnabled = true
            })
        }
        
      
    }
    
    func handeRemoveMathes(){
        self.level.detectedPossibleSwaps()
        
        let setChain = self.level.removeMatches()
       
        if !setChain.isEmpty{
            for chain in setChain{
                score += chain.score
                updateLabels()
            }
            
            scene.animateMatchedCookies(setChain, comletion: {
                
                let arrayColumnRemoveCookies =  self.level.fillHoles()
                self.scene.animateFallingCookies(columns:  arrayColumnRemoveCookies, completion: {
                    
                    let arrayColumnNewCookies =  self.level.topUpCookies()
                    self.scene.animateNewCookies(arrayColumn: arrayColumnNewCookies, comletion: {
                        self.handeRemoveMathes()
                    })
                })
            })
        }else{
             level.resetComboMultiplier()
             self.view.isUserInteractionEnabled = true
        }
        
       let arrayColumnNewCookies =  self.level.topUpCookies()
//
        scene.animateNewCookies(arrayColumn: arrayColumnNewCookies, comletion: {
            self.view.isUserInteractionEnabled = true
        })
        
        
    }
    
    func updateLabels(){
        targetLabel.text = String(format: "%ld", level.targetScore)
        moveLabel.text =  String(format: "%ld", moves)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func beginGame()  {
        moves = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        shuffle()
    }
    
    func shuffle()  {
        let newCookies = level.shuffle()
        scene.addSprite(cookies: newCookies)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait,UIInterfaceOrientationMask.portraitUpsideDown]
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func decrementMoves(){
        moves -= 1
        updateLabels()
    }
}

