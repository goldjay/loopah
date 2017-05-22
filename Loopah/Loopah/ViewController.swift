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
    
    var mySound: AVAudioPlayer!
    //var coder: NSDecoder

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
            //let mySound = try AVAudioPlayer(contentsOf: url)
            //sound = sound
            //sound.play()
        } catch {
            print("Couldn't load file :(")
        }
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        print(sender.value)
        
        sender.isContinuous = false // stops continuous updating
        
        for case let btn as AudioButton in self.view.subviews {
            print(btn.btnSelected)
            if(btn.isSelected){
                btn.avNode.pause()
                btn.avNode.scheduleBuffer(btn.buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
                btn.pitchVal = sender.value
                btn.avNode.play()
                print("PitchVal is now \(btn.pitchVal)")
            }
        }
    }
    @IBAction func reverbChanged(_ sender: UISlider) {
        sender.isContinuous = false // stops continuous updating
        print(sender.value)
        
        for case let btn as AudioButton in self.view.subviews {
            if(btn.btnSelected){
                btn.reverbVal = sender.value
                print("SELECTED")
                print(btn.reverbVal)
                /*
                switch(sender.value){
                    
                    
                case 0..<10:
                    btn.reverbUnit.wetDryMix = 0
                    
                case 10..<20:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.smallRoom)
                    break
                case 20..<30:
                    
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.smallRoom)
                    break
                    
                case 30..<40:
                    
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumRoom)
                    break
                    
                case 40..<50:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.largeRoom)
                    break
                    
                case 50..<60:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumHall)
                    break
                    
                case 60..<70:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall)
                    break
                case 70..<80:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumHall)
                    break
                case 80..<90:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.smallRoom)
                    break
                case 90..<100:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.plate)
                    break
                case 100..<110:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumChamber)
                    break
                case 110..<120:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.largeChamber)
                    break
                    
                case 120..<130:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
                    break
                case 130..<140:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.largeRoom2)
                    break
                case 140..<150:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumHall2)
                    break
                case 150..<160:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.mediumHall3)
                    break
                case 160..<170:
                    btn.reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall2)
                    break
                 
                }
 */
            }
 
        }
    }
    

}

