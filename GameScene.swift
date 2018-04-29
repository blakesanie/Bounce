//
//  GameScene.swift
//  bounce
//
//  Created by Blake Sanie on 6/23/17.
//  Copyright © 2017 Blake Sanie. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

struct physicsCategory {
    static let Enemy :UInt32 = 0x1 << 1
    static let Doctor :UInt32 = 0x1 << 2
    static let Square :UInt32 = 0x1 << 3
}

var isPaused = false
var gameStarted = false
var resumeClicked = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var square = SKSpriteNode()
    var tap = SKLabelNode(fontNamed: "Avenir-light")
    var to = SKLabelNode(fontNamed: "Avenir-light")
    var begin = SKLabelNode(fontNamed: "Avenir-light")
    var score = SKLabelNode(fontNamed: "Avenir-light")
    var lives = SKLabelNode(fontNamed: "Avenir-light")
    var resumeText = SKLabelNode(fontNamed: "Avenir-light")
    var highScore = SKLabelNode(fontNamed: "Avenir-light")
    var pauseText = SKLabelNode(fontNamed: "Avenir-light")
    var newText = SKLabelNode(fontNamed: "Avenir-heavy")
    var fadeLayer = SKSpriteNode()
    
    var enemyTimer = Timer()
    var boundsTimer = Timer()
    
    var scoreVal = 0
    var livesVal = 3
    var highScoreVal = 0
    var newGame = true
    
    let numerals = ["I","I I","I I I"]
    
    let C = SKAction.playSoundFileNamed("Cmaj.mp3", waitForCompletion: false)
    let G = SKAction.playSoundFileNamed("Gmaj.mp3", waitForCompletion: false)
    let endSong = SKAction.playSoundFileNamed("end.mp3", waitForCompletion: false)
    
    override func sceneDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name(rawValue: "pause"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resume), name: NSNotification.Name(rawValue: "resume"), object: nil)
        
        if (UserDefaults.standard.integer(forKey: "hs")) < 1 {
            UserDefaults.standard.set(0, forKey: "hs")
        }
        //UserDefaults.standard.set(0, forKey: "hs") //reset HS for testing purposes
        highScoreVal = UserDefaults.standard.integer(forKey: "hs")
    }
    
    @objc func pauseGame() {
        if !isPaused {
            self.view?.isPaused = true
            if gameStarted {
                fade = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fadeout"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showScreen"), object: nil)
            }
            isPaused = true
            enemyTimer.invalidate()
            boundsTimer.invalidate()
            print("pause")
        }
    }
    
    @objc func resume() {
        if isPaused {
            isPaused = false
            self.view?.isPaused = false
            fade = false
            if gameStarted {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fadein"), object: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeScreen"), object: nil)
            resumeText.alpha = 0.0
            fadeLayer.alpha = 0.0
            enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.enemies), userInfo: nil, repeats: true)
            boundsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.bounds), userInfo: nil, repeats: true)
            resumeClicked = false
            print("resume")
        }
    }
    
    func start() {
        gameStarted = false
        
        fade = true
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fadeout"), object: nil)
        
        let flicker = SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.fadeAlpha(to: 0.1, duration: 0.8)]))
        //enemyTimer.invalidate()
        //boundsTimer.invalidate()
        
        tap.run(flicker)
        to.run(flicker)
        begin.run(flicker)
        //enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.enemies), userInfo: nil, repeats: true)
        //boundsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.bounds), userInfo: nil, repeats: true)
        if newGame {
            score.text = "Bounce"
            score.xScale = 1.4
            score.yScale = 1.4
            enemyTimer.fire()
        } else {
            score.text = "Score: \(scoreVal)"
            score.run(SKAction.scale(by: 1.4, duration: 1))
        }
        
        lives.run(SKAction.fadeOut(withDuration: 0.5))
        highScore.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    override func didMove(to view: SKView) {
        
        tap.text = "Tap"
        tap.verticalAlignmentMode = .center
        tap.position = CGPoint(x: 0, y: 120)
        tap.fontSize = 90
        tap.fontColor = UIColor.white
        tap.zPosition = 3
        
        to.text = "to"
        to.verticalAlignmentMode = .center
        to.position = CGPoint(x: 0, y: 0)
        to.fontSize = 90
        to.fontColor = UIColor.white
        to.zPosition = 3
        
        begin.text = "Begin"
        begin.verticalAlignmentMode = .center
        begin.position = CGPoint(x: 0, y: -120)
        begin.fontSize = 90
        begin.fontColor = UIColor.white
        begin.zPosition = 3
        
        highScore.text = "High Score: \(highScoreVal)"
        highScore.verticalAlignmentMode = .center
        highScore.position = CGPoint(x: 0, y: -560)
        highScore.fontSize = 90
        highScore.fontColor = UIColor.black
        highScore.zPosition = 3
        
        newText.text = "New"
        newText.verticalAlignmentMode = .center
        newText.position = CGPoint(x: 0, y: -460)
        newText.fontSize = 80
        newText.fontColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        newText.zPosition = 3
        newText.alpha = 0.0
        
        score.verticalAlignmentMode = .baseline
        score.position = CGPoint(x: 0, y: 505)
        score.fontSize = 115
        score.fontColor = UIColor.black
        score.alpha = 1
        score.zPosition = 3
        
        lives.verticalAlignmentMode = .center
        lives.position = CGPoint(x: 0, y: 0)
        lives.zPosition = 99
        lives.fontSize = 115
        lives.fontColor = UIColor.white
        lives.zPosition = 3
        
        self.size = CGSize(width: 1080, height: 1920)
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = UIColor.white
        
        
        square.size = CGSize(width: 550, height: 550)
        square.position = CGPoint(x: 0, y: 0)
        square.color = UIColor.black
        square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 550, height: 550))
        square.physicsBody?.isDynamic = false
        square.physicsBody?.allowsRotation = false
        square.physicsBody?.pinned = false
        square.physicsBody?.affectedByGravity = false
        square.physicsBody?.friction = 0
        square.physicsBody?.restitution = 1
        square.zPosition = 2
        square.name = "square"
        
        square.physicsBody?.categoryBitMask = physicsCategory.Square
        square.physicsBody?.collisionBitMask = physicsCategory.Doctor | physicsCategory.Enemy
        square.physicsBody?.contactTestBitMask = physicsCategory.Doctor | physicsCategory.Enemy
        
        self.addChild(square)
        self.addChild(tap)
        self.addChild(to)
        self.addChild(begin)
        self.addChild(score)
        self.addChild(lives)
        self.addChild(highScore)
        self.addChild(newText)
        self.physicsWorld.contactDelegate = self
        
        start()
        enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.enemies), userInfo: nil, repeats: true)
        boundsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.bounds), userInfo: nil, repeats: true)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode
        let relativeAngle = abs(square.zRotation.truncatingRemainder(dividingBy: CGFloat(0.5 * .pi)))
        let diagonal = (relativeAngle > 0.72 || relativeAngle < 0.81)
        let vertical = (relativeAngle < 0.04 || relativeAngle > 1.2)
        
        if (firstBody.name == "vertEn" && secondBody.name == "vertDoc") || (firstBody.name == "vertDoc" && secondBody.name == "vertEn") || (firstBody.name == "diagEn" && secondBody.name == "diagDoc") || (firstBody.name == "diagDoc" && secondBody.name == "diagEn") || (firstBody.name == "green" && (secondBody.name == "diagDoc" || secondBody.name == "vertDoc")) || (secondBody.name == "green" && (firstBody.name == "diagDoc" || firstBody.name == "vertDoc")) {
            firstBody.physicsBody?.categoryBitMask = 0
            firstBody.physicsBody?.collisionBitMask = 0
            firstBody.physicsBody?.contactTestBitMask = 0
            secondBody.physicsBody?.categoryBitMask = 0
            secondBody.physicsBody?.collisionBitMask = 0
            secondBody.physicsBody?.contactTestBitMask = 0
            if gameStarted {
                if firstBody.name == "green" || secondBody.name == "green" {
                    if volume {
                        run(C)
                        run(G)
                    }
                    if livesVal < 3 {
                        livesVal += 1
                        lives.text = "\(numerals[livesVal - 1])"
                    }
                } else {
                    if volume {
                        run(C)
                    }
                }
                scoreVal += 1
                score.text = String(scoreVal)
            }
            firstBody.name = "blank"
            secondBody.name = "blank"
        }
        if (((firstBody.name == "vertDoc" && secondBody.name == "square") || (firstBody.name == "square" && secondBody.name == "vertDoc")) && !vertical) || (((firstBody.name == "diagDoc" && secondBody.name == "square") || (firstBody.name == "square" && secondBody.name == "diagDoc")) && !diagonal)  {
            if (firstBody.name == "square") {
                secondBody.physicsBody?.categoryBitMask = 0
                secondBody.physicsBody?.collisionBitMask = 0
                secondBody.physicsBody?.contactTestBitMask = 0
                secondBody.name = "blank"
            } else {
                firstBody.physicsBody?.categoryBitMask = 0
                firstBody.physicsBody?.collisionBitMask = 0
                firstBody.physicsBody?.contactTestBitMask = 0
                firstBody.name = "blank"
            }
        }
        
        if (firstBody.name == "square" && secondBody.name != "vertDoc" && secondBody.name != "diagDoc" && secondBody.name != "blank") || (secondBody.name == "square" && firstBody.name != "vertDoc" && firstBody.name != "diagDoc" && firstBody.name != "blank") {
            if gameStarted {
            livesVal -= 1
            flash()
            }
            if (firstBody.name == "square") {
                secondBody.physicsBody?.categoryBitMask = 0
                secondBody.physicsBody?.collisionBitMask = 0
                secondBody.physicsBody?.contactTestBitMask = 0
                secondBody.name = "blank"
                if gameStarted {
                secondBody.removeFromParent()
                }
            } else {
                firstBody.physicsBody?.categoryBitMask = 0
                firstBody.physicsBody?.collisionBitMask = 0
                firstBody.physicsBody?.contactTestBitMask = 0
                firstBody.name = "blank"
                if gameStarted {
                firstBody.removeFromParent()
                }
            }
            if gameStarted {
            if (livesVal <= 0) {
                if scoreVal > highScoreVal {
                    highScoreVal = scoreVal
                    UserDefaults.standard.set(scoreVal, forKey: "hs")
                    highScore.text = "Highscore: \(highScoreVal)"
                    newText.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.fadeAlpha(to: 0.1, duration: 0.8)])))
                }
                if volume {
                run(endSong)
                }
                start()
            } else {
                if volume {
                run(G)
                }
                lives.text = String(numerals[livesVal - 1])
            }
            }
        }
    }
    
    func flash() {
        square.run(SKAction.sequence([SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.1), SKAction.colorize(with: UIColor.black, colorBlendFactor: 1.0, duration: 0.1)]))
    }
    
    @objc func bounds() {
        for child in self.children {
            if (child.name == "blank" && distance(object: child) > 1275.0) {
                child.removeFromParent()
            }
        }
    }
    
    func distance(object : SKNode) -> Double {
        return Double(sqrt((object.position.x * object.position.x) + (object.position.y * object.position.y)))
    }
    
    func offscreen(object: SKNode) ->Bool {
        let x = object.position.x
        let y = object.position.y
        return((x > 565) || (x < -565) || (y > 985) || (y < -985))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (!gameStarted) {
                if newGame || score.xScale > 1.35 {
                    newGame = false
                enemyTimer.invalidate()
                boundsTimer.invalidate()
                tap.removeAllActions()
                to.removeAllActions()
                begin.removeAllActions()
                newText.removeAllActions()
                for child in self.children {
                    if (child.name == "blank" || child.name == "diagEn" || child.name == "diagDoc" || child.name == "vertEn" || child.name == "vertDoc" || child.name == "green") {
                        child.name = "blank"
                        child.run(SKAction.fadeOut(withDuration: 0.5), completion: child.removeFromParent)
                    }
                }
                tap.run(SKAction.fadeOut(withDuration: 0.5))
                to.run(SKAction.fadeOut(withDuration: 0.5))
                begin.run(SKAction.fadeOut(withDuration: 0.5))
                newText.run(SKAction.fadeOut(withDuration: 0.5))
                highScore.run(SKAction.fadeOut(withDuration: 0.5))
                score.run(SKAction.fadeIn(withDuration: 1))
                score.run(SKAction.scale(to: 1, duration: 1))
                lives.run(SKAction.fadeIn(withDuration: 1))
                enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.enemies), userInfo: nil, repeats: true)
                boundsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.bounds), userInfo: nil, repeats: true)
                scoreVal = 0
                livesVal = 3
                score.text = "0"
                lives.text = "I I I"
                gameStarted = true
                fade = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fadein"), object: nil)
                }
            } else {
                if isPaused {
                    print("clicked")
                    resumeClicked = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countdown"), object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        self.resume()
                    })
                } else {
                    if touch.location(in: self).x > 0 {
                        square.run(SKAction.rotate(byAngle: -.pi / 4, duration: 0.07))
                    } else {
                        square.run(SKAction.rotate(byAngle: .pi / 4, duration: 0.07))
                    }
                }
            }
        }
    }
  
    @objc func enemies() {
        
        let isGreen = Int(arc4random_uniform(25)) == 5
        
        
        var enemy = SKSpriteNode(imageNamed: "player")
        if isGreen {
            enemy = SKSpriteNode(imageNamed: "green")
        }
        enemy.size = CGSize(width: 50, height: 50)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.pinned = false
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.restitution = 1
        enemy.zPosition = 1
        
        
        enemy.physicsBody?.categoryBitMask = physicsCategory.Enemy
        enemy.physicsBody?.collisionBitMask = physicsCategory.Doctor | physicsCategory.Square
        enemy.physicsBody?.contactTestBitMask = physicsCategory.Doctor | physicsCategory.Square
        
        
        let doctor = SKSpriteNode(imageNamed: "doctor")
        doctor.size = CGSize(width: 50, height: 50)
        doctor.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        doctor.physicsBody?.isDynamic = true
        doctor.physicsBody?.allowsRotation = false
        doctor.physicsBody?.pinned = false
        doctor.physicsBody?.affectedByGravity = false
        doctor.physicsBody?.friction = 0
        doctor.physicsBody?.restitution = 1
        doctor.physicsBody?.mass = 1000
        doctor.zPosition = 1
        
        doctor.physicsBody?.categoryBitMask = physicsCategory.Doctor
        doctor.physicsBody?.collisionBitMask = physicsCategory.Square | physicsCategory.Enemy
        doctor.physicsBody?.contactTestBitMask = physicsCategory.Square | physicsCategory.Enemy
        
        let num = Int(arc4random_uniform(8))
        let speed = 480.0
        
        switch num {
        case 0:
            let randPos = Int(arc4random_uniform(501))
            doctor.position = CGPoint(x: (randPos - 250), y: 1150)
            enemy.position = CGPoint(x: (randPos - 250), y: (1250))
            doctor.physicsBody?.velocity = CGVector(dx: 0, dy: -speed)
            enemy.physicsBody?.velocity = CGVector(dx: 0, dy: -speed)
            break
        case 1:
            let randPos = Int(arc4random_uniform(390))
            doctor.position = CGPoint(x: 636 + randPos, y: 1025 - randPos)
            enemy.position = CGPoint(x: 707 + randPos, y: 1096 - randPos)
            doctor.physicsBody?.velocity = CGVector(dx: -speed / sqrt(2), dy: -speed / sqrt(2))
            enemy.physicsBody?.velocity = CGVector(dx: -speed / sqrt(2), dy: -speed / sqrt(2))
            break
        case 2:
            let randPos = Int(arc4random_uniform(501))
            doctor.position = CGPoint(x: 1150, y: (randPos - 250))
            enemy.position = CGPoint(x: 1250, y: (randPos - 250))
            doctor.physicsBody?.velocity = CGVector(dx: -speed, dy: 0)
            enemy.physicsBody?.velocity = CGVector(dx: -speed, dy: 0)
            break
        case 3:
            let randPos = Int(arc4random_uniform(390))
            doctor.position = CGPoint(x: 636 + randPos, y: -1025 + randPos)
            enemy.position = CGPoint(x: 707 + randPos, y: -1096 + randPos)
            doctor.physicsBody?.velocity = CGVector(dx: -speed / sqrt(2), dy: speed / sqrt(2))
            enemy.physicsBody?.velocity = CGVector(dx: -speed / sqrt(2), dy: speed / sqrt(2))
            break
        case 4:
            let randPos = Int(arc4random_uniform(501))
            doctor.position = CGPoint(x: (randPos - 250), y: -1150)
            enemy.position = CGPoint(x: (randPos - 250), y: -1250)
            doctor.physicsBody?.velocity = CGVector(dx: 0, dy: speed)
            enemy.physicsBody?.velocity = CGVector(dx: 0, dy: speed)
            break
        case 5:
            let randPos = Int(arc4random_uniform(390))
            doctor.position = CGPoint(x: -636 - randPos, y: -1025 + randPos)
            enemy.position = CGPoint(x: -707 - randPos, y: -1096 + randPos)
            doctor.physicsBody?.velocity = CGVector(dx: speed / sqrt(2), dy: speed / sqrt(2))
            enemy.physicsBody?.velocity = CGVector(dx: speed / sqrt(2), dy: speed / sqrt(2))
            break
        case 6:
            let randPos = Int(arc4random_uniform(501))
            doctor.position = CGPoint(x: -1150, y: (randPos - 250))
            enemy.position = CGPoint(x: -1250, y: (randPos - 250))
            doctor.physicsBody?.velocity = CGVector(dx: speed, dy: 0)
            enemy.physicsBody?.velocity = CGVector(dx: speed, dy: 0)
            break
        case 7:
            let randPos = Int(arc4random_uniform(390))
            doctor.position = CGPoint(x: -636 - randPos, y: 1025 - randPos)
            enemy.position = CGPoint(x: -707 - randPos, y: 1096 - randPos)
            doctor.physicsBody?.velocity = CGVector(dx: speed / sqrt(2), dy: -speed / sqrt(2))
            enemy.physicsBody?.velocity = CGVector(dx: speed / sqrt(2), dy: -speed / sqrt(2))
            break
        default:
            break
        }
        
        if (num % 2 == 0) {
            doctor.name = "vertDoc"
            enemy.name = "vertEn"
        } else {
            doctor.name = "diagDoc"
            enemy.name = "diagEn"
        }
        
        if isGreen {
            enemy.name = "green"
        }
        
        self.addChild(doctor)
        self.addChild(enemy)
    }
}
