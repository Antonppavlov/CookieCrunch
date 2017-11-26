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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {

            view.isMultipleTouchEnabled = false
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            self.scene = GameScene(size: view.bounds.size)
            self.scene.scaleMode = .aspectFit
            
            self.level = Level(fileName: "Level_1")
            self.scene.level = level
            
            view.presentScene(scene)
          
        }
        
        
        beginGame()
    }
    
    func beginGame()  {
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
}

