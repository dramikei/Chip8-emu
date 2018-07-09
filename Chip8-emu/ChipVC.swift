//
//  ViewController.swift
//  Chip8-emu
//
//  Created by Raghav Vashisht on 09/07/18.
//  Copyright © 2018 Raghav Vashisht. All rights reserved.
//

import UIKit

class ChipVC: UIViewController {
    
    var chip8: Chip8!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

