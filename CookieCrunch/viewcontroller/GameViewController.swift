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
import AVFoundation


class GameViewController: UIViewController {
    
    var scene:GameScene!
    var level:Level!
    
    var moves = 0
    var score = 0
    var currentLevelNum = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var tapGestureRecognizer: UIGestureRecognizer?
    
    lazy var backgroundMusic:AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3")else {return nil}
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        }catch{
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLevelNum(levelNum: currentLevelNum)
        backgroundMusic?.play()
    }
    
    func setupLevelNum(levelNum: Int){
        if let view = self.view as! SKView? {
            
            view.isMultipleTouchEnabled = false
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            self.scene = GameScene(size: view.bounds.size)
            self.scene.scaleMode = .aspectFit
            
            self.level = Level(fileName: "Level_\(levelNum)")
            self.scene.level = level
            
            self.scene.swapHandler = hangleSwape(_:)
            
            gameOverPanel.isHidden = true
            shuffleButton.isHidden = true
            view.presentScene(scene)
            
            beginGame()
        }
    }
   
    
    func beginGame()  {
      
        moves = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame {
            
            self.shuffleButton.isHidden = false
        }
        shuffle()
    }
    
    @IBAction func shuffleButtonPressed(_ sender: Any) {
        shuffle()
        decrementMoves()
    }
    
    func shuffle()  {
        
        scene.removeAllCookiesSprite()
        scene.addTiles()
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }
    
    
    func showGameOverPanel(){
        shuffleButton.isHidden = true
        gameOverPanel.isHidden = false
        scene.isUserInteractionEnabled = false
        
        scene.animateGameOver {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer!)
        }
    }
    
    @objc func hideGameOver(){
        view.removeGestureRecognizer(self.tapGestureRecognizer!)
        tapGestureRecognizer = nil
        gameOverPanel.isHidden = true
        scene.isUserInteractionEnabled = true
        
        setupLevelNum(levelNum: currentLevelNum)
      //  beginGame()
    }
    
    func hangleSwape(_ swap: Swap){
        self.level.detectedPossibleSwaps()
        view.isUserInteractionEnabled = false
        
        if level.isPosibleSwap(swap: swap){
            
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
            decrementMoves()
            level.resetComboMultiplier()
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    func updateLabels(){
        targetLabel.text = String(format: "%ld", level.targetScore)
        moveLabel.text =  String(format: "%ld", moves)
        scoreLabel.text = String(format: "%ld", score)
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
        
        if(score >= level.targetScore){

            gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevelNum = currentLevelNum < NumLevel ? currentLevelNum + 1 : 1
            showGameOverPanel()
        }else if(moves == 0){
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOverPanel()
        }
        
    }
}



