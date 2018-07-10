//
//  Chip8.swift
//  Chip8-emu
//
//  Created by Raghav Vashisht on 09/07/18.
//  Copyright © 2018 Raghav Vashisht. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Word = UInt16

class Chip8 {
    
    private var stack: [Word]
    private var stackPointer: Word
    private var memory: [Byte]
    private var V: [Byte]
    private var I: Word
    private var pc: Word
    private var delay_timer: Byte
    private var sound_timer: Byte
    private var keys: [Byte]
    private var display: [Byte]
    private var needRedraw: Bool
    
    init() {
        memory = [Byte](repeating: 0, count: 0xFFF)
        V = [Byte](repeating: 0, count: 16)
        I = 0x0
        pc = 0x200
        
        stack = [Word](repeating: 0, count: 16)
        stackPointer = 0
        
        delay_timer = 0
        sound_timer = 0
        
        keys = [Byte](repeating: 0, count: 16)
        display = [Byte](repeating: 0, count: 64*32)
        needRedraw = false
        
        //loadFontset()
    }
    
    func run() {
        var opcode: Word = Word(Int(memory[Int(pc)]) << 8 | Int(memory[Int(pc) + 1]))
        print("opcode: " + printHex(Int(opcode)))
        
        switch(opcode & 0xF000) {
            
        case 0x8000:
            
            
            switch(opcode & 0x000F) {
            case 0x000:
                //8XY0: Sets VX to the value of VY.
                break
            default:
                print("Unsupported opcode! in case 8000")
                break
            }
            
            
            break
            
            
        default:
            print("Unsupported opcode!")
            break
        }
        
    }
    
    func loadGame(rom: Array<Byte>) {
        var i = 0
        while i < rom.count {
            memory[0x200 + i] = rom[i]
            i += 1
        }
    }
    
    func getDisplay() -> [Byte] { return display }
    
    func needsRedraw() -> Bool { return needRedraw }
    
    func removeDrawFlag() { needRedraw = false }
    
    
    func printHex(_ x: Int) -> String {
        let y = String(x, radix: 16, uppercase: true)
        return "0x\(y)"
    }
}
