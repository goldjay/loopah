//
//  ViewController.swift
//  Loopah
//
//  Created by Jay Steingold on 5/1/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var bombSoundEffect: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func playFile(_ sender: AnyObject) {
        
        let path = Bundle.main.path(forResource: "recording1.m4a", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            //bombSoundEffect = sound
            //sound.play()
        } catch {
            // couldn't load file :(
        }
    }


}

