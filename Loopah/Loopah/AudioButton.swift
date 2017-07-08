//
//  AudioButton.swift
//  Loopah
//
//  Created by Jay Steingold on 5/1/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

import UIKit
import AVFoundation

class AudioButton: UIButton, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var frameHeight: CGFloat?
    var frameWidth: CGFloat?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioEngine: AVAudioEngine!
    var playerA: AVAudioPlayerNode!
    var file: AVAudioFile!
    
    var player : AVAudioPlayer?
    
    var buttonColor: UIColor?
    var buttonHeight: Int?
    var buttonWidth: Int?
    
    
    var audioFileName: URL? = nil
    var btnSelected: Bool = false
    
    var distorsionVal: Float = 0 {
        didSet {
            playerA.pause()
            distortionUnit.wetDryMix = distorsionVal
            
            startAudioAfterChange()
        }
    }
    
    var pitchVal: Float = 0 {
        didSet {
            playerA.pause()
            pitchUnit.pitch = pitchVal
            startAudioAfterChange()
        }
    }
    var reverbVal: Float = 0 {
        didSet {
            playerA.pause()
            reverbUnit.wetDryMix = reverbVal
            startAudioAfterChange()
        }
    }
    
    var playBackVal: Float = 1 {
        didSet {
            playerA.pause()
            pitchUnit.rate = playBackVal
            startAudioAfterChange()
        }
    }
    
    let pitchUnit = AVAudioUnitTimePitch()
    let reverbUnit = AVAudioUnitReverb()
    let distortionUnit = AVAudioUnitDistortion()
    
    var buffer: AVAudioPCMBuffer!
    
    required init(dimensions: Int, activeColor: UIColor) {
        super.init(frame: .zero)
        
        // Create a shape at the position and of the size
        buttonColor = activeColor
        
        
        
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.setTitleColor(buttonColor, for: .normal)
        
        // Create record button
        let recDim = Int(dimensions/7)
        
        let recBtn = UIButton(frame: CGRect(x: 5, y: 5, width: recDim, height: recDim))
        recBtn.backgroundColor = UIColor.red
        
        recBtn.layer.cornerRadius = 0.5 * recBtn.bounds.size.width
        recBtn.clipsToBounds = true
        recBtn.layer.masksToBounds = true
        recBtn.layer.zPosition = 10
        recBtn.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        addSubview(recBtn)
        
        // Create select button
        
        let selectDim = Int(dimensions/6)
        
        let selectBtn = UIButton(frame: CGRect(x: Int(dimensions) - selectDim, y: 0, width: selectDim, height: selectDim))
        selectBtn.layer.zPosition = 10
        selectBtn.backgroundColor = UIColor.red
        selectBtn.addTarget(self, action: #selector(handleSelectButtonPress(sender:)), for: .touchUpInside)
        addSubview(selectBtn)
        
        
        
        
        // Set gesture recognizers
        
        let buttonTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        self.addGestureRecognizer(buttonTapped)
        
        // Set up Audio Recording
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("ALLOWED")
                    } else {
                        // failed to record!
                        print("FAILED TO RECORD: NOT ALLOWED")
                    }
                }
            }
        } catch {
            // failed to record!
            print("FAILED TO RECORD!")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleSelectButtonPress(sender: UIButton!) {
        print("HIT THE MENU BUTTON")
        
        btnSelected = !btnSelected
        
        if(btnSelected) {
            self.layer.borderWidth = 5
        } else {
            self.layer.borderWidth = 1
        }
    }
    
    func startRecording(sender: UIButton) {
        // Check if you are currently recording
        if(audioRecorder != nil && audioRecorder.isRecording) {
            finishRecording(sender: sender, success: true)
        } else {
            audioFileName = getDocumentsDirectory().appendingPathComponent("recording\(self.tag).m4a")
            
            print(audioFileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Change the title of the button to blink
            do {
                print("NOW RECORDING")
                audioRecorder = try AVAudioRecorder(url: audioFileName!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                // Start the button flashing
                buttonFlash(sender: sender, color: UIColor.white)
                
                
            } catch {
                finishRecording(sender: sender, success: false)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(sender: UIButton, success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        playerA = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        
        if success {
            do {
                playAudioEngine()
                print("SUCCESSFUL RECORDING. NOW PLAYING")
                sender.layer.removeAllAnimations() // Stop button flash
                sender.backgroundColor = UIColor.red
            }
        } else {
            print("UNSUCCESSFUL RECORDING")
        }
    }
    
    func playAudioEngine() {
        do{
            file = try AVAudioFile(forReading: audioFileName!)
            buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            try file.read(into: buffer)
            
            // Add some reverb
            reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
            reverbUnit.wetDryMix = 0
            
            // Add some distorsion
            distortionUnit.loadFactoryPreset(AVAudioUnitDistortionPreset.speechRadioTower)
            distortionUnit.wetDryMix = 0
            
            pitchUnit.pitch = 0
            
            // Attach the four nodes to the audio engine
            audioEngine.attach(playerA)
            audioEngine.attach(reverbUnit)
            audioEngine.attach(distortionUnit)
            audioEngine.attach(pitchUnit)
            
            // Connection chain
            audioEngine.connect(playerA, to: pitchUnit, format: buffer.format)
            audioEngine.connect(pitchUnit, to: reverbUnit, format: buffer.format)
            audioEngine.connect(reverbUnit, to: distortionUnit, format: buffer.format)
            audioEngine.connect(distortionUnit, to: audioEngine.mainMixerNode, format: buffer.format)
            
            // Schedule sound to play on buffer in a loop
            playerA.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            
            // Start the audio engine
            audioEngine.prepare()
            try audioEngine.start()
            //playerA.play()
            
        } catch {
            print("Playing didn't work")
        }
        
    }
    /*
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(sendersuccess: false)
            print("DidFinish FALSE")
        } else {
            print("DidFinish TRUE")
        }
    }
    */
    
    func handleTap(sender: UITapGestureRecognizer) {
        if let button = sender.view as? UIButton {
            if(audioFileName != nil){
                if playerA.isPlaying {
                    playerA.pause()
                    button.backgroundColor = UIColor.white
                    button.setTitleColor(self.buttonColor, for: .normal)
                    
                } else {
                    playerA.play()
                    button.backgroundColor = buttonColor
                    button.setTitleColor(.white, for: .normal)
                }
            }
        }
    }
    
    func startAudioAfterChange() {
        playerA.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        // Start the audio engine
        audioEngine.prepare()
        do{
            try audioEngine.start()
            playerA.play()
        }catch{
            print("Couldn't play")
        }
    }
    
    func buttonFlash(sender: UIButton, color: UIColor){
        //Fade in
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            sender.backgroundColor = color
            sender.setTitleColor(UIColor.white, for: UIControlState.normal)
        }, completion: nil)
    }
}
