//
//  GameViewController.swift
//  bounce
//
//  Created by Blake Sanie on 6/23/17.
//  Copyright © 2017 Blake Sanie. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var fade = true
var volume = true

class GameViewController: UIViewController {
    
    @IBOutlet weak var pauseScreen: UIView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadePauseIn), name: NSNotification.Name(rawValue: "fadein"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fadePauseOut), name: NSNotification.Name(rawValue: "fadeout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showScreen), name: NSNotification.Name(rawValue: "showScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeScreen), name: NSNotification.Name(rawValue: "removeScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(countdown), name: NSNotification.Name(rawValue: "countdown"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    @IBAction func pausePressed(_ sender: Any) {
        if !isPaused && gameStarted {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pause"), object: nil)
        }
    }
    
    @objc func fadePauseIn() {
        if fade {
            UIView.animate(withDuration: 0.5, animations: { self.pauseButton.alpha = 1.0 }, completion: nil)
        } else {
            pauseButton.alpha = 1.0
        }
    }
    
    @objc func fadePauseOut() {
        if fade {
            UIView.animate(withDuration: 0.5, animations: { self.pauseButton.alpha = 0.0 }, completion: nil)
        } else {
            pauseButton.alpha = 0.0
        }
    }
    
    @objc func showScreen() {
        pauseScreen.alpha = 0.95
        resumeText.text = "resume"
        resumeText.alpha = 1.0
    }
    
    @objc func removeScreen() {
        pauseScreen.alpha = 0.0
        resumeText.alpha = 0.0
    }
    
    @objc func countdown() {
        resumeText.text = "3"
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.resumeText.text = "2"
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.resumeText.text = "1"
            })
        })
    }
    
    @IBAction func switched(_ sender: Any) {
        volume = !volume
        print(volume)
    }
    
    @IBAction func seeInstructions(_ sender: Any) {
        if !resumeClicked {
            performSegue(withIdentifier: "goToInst", sender: self)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}





class Instructions: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var myPageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: myCollectionView.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        myCollectionView.collectionViewLayout = layout

        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let image = cell.viewWithTag(1) as! UIImageView
        image.image = UIImage(named: "Bounce_instructions_\(indexPath.section + 1)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        myPageControl.currentPage = indexPath.section
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
