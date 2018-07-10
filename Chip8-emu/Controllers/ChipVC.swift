//
//  ViewController.swift
//  Chip8-emu
//
//  Created by Raghav Vashisht on 09/07/18.
//  Copyright © 2018 Raghav Vashisht. All rights reserved.
//

import UIKit
import SpriteKit

class ChipVC: UIViewController {
    
    @IBOutlet weak var skView: SKView!
    var scene: SKScene!
    var emuTimer: Timer!
    
    
    var chip8: Chip8!

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = SKScene()
        chip8 = Chip8()
        getGame()
        createSceneContent()
        presentDisplay()
        skView.presentScene(scene)
        self.emuTimer = Timer.scheduledTimer(timeInterval: 1/500.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        chip8.run()
        if chip8.needsRedraw() {
            presentDisplay()
            chip8.removeDrawFlag()
        }
    }
    
    func createSceneContent() {
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0, y: 1)
        scene.backgroundColor = .black
        scene.size = CGSize(width: 64, height: 32)
    }
    
    func presentDisplay() {
        scene.removeAllChildren()
        let display = chip8.getDisplay()
        var i = 0
        while i < display.count {
            let point: SKSpriteNode!
            if display[i] == 1 {
                point = SKSpriteNode(color: .white, size: CGSize(width: 1, height: 1))
                let x = i % 64
                let y = -(Int(floor(Double(i / 64))))
                point.position = CGPoint(x: x, y: y)
                point.anchorPoint = CGPoint(x: 0, y: 1)
                scene.addChild(point)
            }
            i += 1
        }
    }
    
    func getGame() {
        do {
            let data = try Data(contentsOf: Bundle.main.url(forResource: "pong", withExtension: "rom")!)
            data.withUnsafeBytes({ (pointer: UnsafePointer<Byte>) in
                let buffer = UnsafeBufferPointer(start: pointer, count: data.count)
                let array = Array<Byte>(buffer)
                chip8.loadGame(rom: array)
            })
        }
        catch {
            print("Error while loading the rom")
        }
    }

}

