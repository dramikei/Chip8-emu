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
            let nnn: Word = Word(opcode & 0x0FFF)
            pc = Word(nnn)
            print("Jumping to \(printHex(Int(pc)))")
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
            print("Setting V[\(x)] to \(V[x])")
            break
            
        case 0x7000:
            let x: Int = Int(opcode & 0x0F00) >> 8
            let nn: Byte = Byte(opcode & 0x00FF)
            V[x] = (V[x] + nn) & 0xFF
            pc += 2
            print("Adding \(nn) to V[\(x)] = \(V[x])")
            break
            
        /////////////
        case 0x8000:
            switch(opcode & 0x000F) {
            case 0x0000:
                //8XY0: Sets VX to the value of VY.
                let x = Int(opcode & 0x0F00) >> 8
                let y = Int(opcode & 0x00F0) >> 4
                print("Setting V[\(x)] to \(V[y])")
                V[x] = V[y]
                pc += 2
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
            
        case 0xC000:
            let x = Int(opcode & 0x0F00) >> 8
            let nn = (opcode & 0x00FF)
            let randomNumber = Int.random(in: 0 ..< 256) & Int(nn)
            V[x] = Byte(randomNumber)
            print("Setting V[\(x)] to a random number: \(randomNumber)")
            pc += 2
            break
            
        case 0xD000:
            
            let x = V[Int(opcode & 0x0F00) >> 8]
            let y = V[Int(opcode & 0x00F0) >> 4]
            let height = opcode & 0x000F
            var pixel: Word
            
            V[0xF] = 0;
            for yline in 0...(height - 1) {
                pixel = Word(memory[Int(I + yline)])
                for xline in 0...7 {
                    if((pixel & (0x80 >> xline)) != 0) {
                        if(display[Int(x) + Int(xline) + ((Int(y) + Int(yline)) * 64)] == 1){
                            V[Int(0xF)] = 1
                        }
                        display[Int(x) + Int(xline) + ((Int(y) + Int(yline)) * 64)] ^= 1
                    }
                }
            }
            needRedraw = true
            pc += 2
            break
            
        /////////////
        case 0xE000:
            switch(opcode & 0x00FF) {
                
            case 0x009E:
                let key: Int = Int(opcode & 0x0F00) >> 8
                if keys[key] == 1 {
                    pc += 4
                } else {
                    pc += 2
                }
                break
                
            case 0x00A1:
                let key: Int = Int(opcode & 0x0F00) >> 8
                if keys[key] == 0 {
                    pc += 4
                } else {
                    pc += 2
                }
                break
                
            default:
                print("Unsupported opcode!")
                break
            }
            break
        /////////////
            
        /////////////
        case 0xF000:
            switch(opcode & 0x00FF) {
                
            case 0x0007:
                let x = Int(opcode & 0x0F00) >> 8
                V[x] = delay_timer
                pc += 2
                print("Setting V[\(x)] to delayTimer = \(delay_timer)")
                break
                
            case 0x0015:
                let x = Int(opcode & 0x0F00) >> 8
                delay_timer = V[x]
                pc += 2
                print("Setting delayTimer to V[\(x)] = \(V[x])")
                break
                
            case 0x0029:
                let x = Int((opcode & 0x0F00)) >> 8
                let character: Byte = V[x]
                I = Word(character * 5)
                print("Setting I to character V[\(x)] = \(V[x]) offset to \(printHex(Int(I)))")
                pc += 2
                break
                
            case 0x0033:
                let x = Int(opcode & 0x0F00) >> 8
                var value = V[x]
                let hundreds = (value - (value % 100)) / 100
                value = value - (hundreds * 100)
                let tens = (value - (value % 10)) / 10
                value = value - (tens * 10)
                let ones = value
                memory[Int(I)] = Byte(hundreds)
                memory[Int(I + 1)] = Byte(tens)
                memory[Int(I + 2)] = Byte(ones)
                print("Storing binary coded decimal V[\(x)] = \(V[x]) as {\(hundreds), \(tens), \(ones)}")
                pc += 2
                break
                
            case 0x0065:
                let x = Int(opcode & 0xF00) >> 8
                for i in 0...(x - 1) {
                    V[i] = memory[Int(I) + i]
                    print(i)
                }
                print("Setting V[0] to V[\(x)] to the values of memory[\(printHex(Int(I & 0xFFFF)))]")
                pc += 2
                break
            default:
                print("Unsupported opcode!")
                break
            }
            break
        /////////////
            
        default:
            print("Unsupported opcode!")
            break
        }
        if sound_timer > 0 {
            sound_timer -= 1
            //playSound()
        }
        if delay_timer > 0 {
            delay_timer -= 1
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
    
    func loadKeys() -> [Byte] {
        return keys
    }
    
    func setKeys(keysArr: [Byte]) {
        keys = keysArr
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
