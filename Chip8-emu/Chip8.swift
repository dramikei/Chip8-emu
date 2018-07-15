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
        
        loadFontset()
    }
    
    func run() {
        let opcode: Word = Word(Int(memory[Int(pc)]) << 8 | Int(memory[Int(pc) + 1]))
        print("opcode: " + printHex(Int(opcode)))
        
        switch(opcode & 0xF000) {
            
        ///////////
        case 0x000:
            switch (opcode & 0x00FF) {
            case 0x00E0:
                print("Unsupported opcode!")
                break
            case 0x00EE:
                stackPointer = stackPointer - 1
                pc = stack[Int(stackPointer)] + 2
                print("Returning to \(printHex(Int(pc)))")
                break
            default:
                print("Unsupported opcode!")
                break
            }
            break
        ///////////
            
        case 0x1000:
            let nnn: Int = Int(opcode & 0x0FFF)
            pc = Word(nnn)
            break
            
        case 0x2000:
            stack[Int(stackPointer)] = pc
            stackPointer += 1
            pc = Word(opcode & 0x0FFF)
            break
            
        case 0x3000:
            let x: Int = (Int(opcode & 0x0F00) >> 8)
            let nn: Int = Int(opcode & 0x00FF)
            if V[x] == nn {
                pc += 4
                print("Skipping next instruction V[\(Int(x))] == \(nn)")
            } else {
                pc += 2
                print("Not skipping next instruction V[\(Int(x))] != \(nn)")
            }
            break
            
        case 0x6000:
            let x: Int = Int(opcode & 0x0F00) >> 8
            V[x] = Byte(opcode & 0x00FF)
            pc += 2
            break
            
        case 0x7000:
            let x: Int = Int(opcode & 0x0F00) >> 8
            let nn: Byte = Byte(opcode & 0x00FF)
            V[x] = (V[x] + nn) & 0xFF
            pc += 2
            break
            
        /////////////
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
        /////////////
            
        case 0xA000:
            I = opcode & 0x0FFF
            pc += 2
            break
            
        case 0xD000:
            let x = V[Int((opcode & 0x0F00) >> 8)]
            let y = V[Int((opcode & 0x00F0) >> 4)]
            let height = opcode & 0x000F
            
            var _x = 0
            var _y = 0
            
            V[0xF] = 0
            
            while _y < height {
                let line = memory[Int(I) + _y]
                while _x < 8 {
                    let pixel = line & (0x80 >> _x)
                    if pixel != 0 {
                        let totalX = Int(x) + _x
                        let totalY = Int(y) + _y
                        let index = (totalY * 64) + totalX
                        
                        if display[Int(index)] == 1 {
                            V[0xF] = 1
                        }
                        
                        display[Int(index)] ^= 1
                    }
                    _x += 1
                }
                _y += 1
            }
            
            pc += 2
            needRedraw = true
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
    
    func loadFontset() {
        memory.replaceSubrange(0..<Chip8.FontSet.count, with: Chip8.FontSet)
    }
    
    private static let FontSet: [Byte] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ]
}
