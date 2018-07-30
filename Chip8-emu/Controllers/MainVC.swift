//
//  MainVC.swift
//  Chip8-emu
//
//  Created by Raghav Vashisht on 09/07/18.
//  Copyright © 2018 Raghav Vashisht. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var roms: [String] = ["pong2", "invaders", "tetris"]
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "romCell")!
        print("Row: \(indexPath.row) rom: \(roms[indexPath.row])")
        cell.textLabel?.text = roms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chipVC = storyboard.instantiateViewController(withIdentifier: "chipVC") as! ChipVC
        chipVC.rom = roms[indexPath.row]
        self.navigationController?.pushViewController(chipVC, animated: true)
    }

}
