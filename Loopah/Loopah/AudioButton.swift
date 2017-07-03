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
    
    var frameHeight: CGFloat = 150
    var frameWidth: CGFloat = 150
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioEngine: AVAudioEngine!
    var playerA: AVAudioPlayerNode!
    var file: AVAudioFile!
    
    
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        let recBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        recBtn.backgroundColor = UIColor.red
        
        recBtn.layer.cornerRadius = 0.5 * recBtn.bounds.size.width
        recBtn.layer.borderWidth = 2.0
        recBtn.clipsToBounds = true
        recBtn.layer.masksToBounds = true
        recBtn.layer.zPosition = 10
        recBtn.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        addSubview(recBtn)
        
        let btn = UIButton(frame: CGRect(x: 100, y: 0, width: 50, height: 50))
        btn.layer.zPosition = 10
        btn.addTarget(self, action: #selector(handleSelectButtonPress(sender:)), for: .touchUpInside)
        addSubview(btn)
        
        // Set gesture recognizers
        
        let buttonTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        //let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(sender:)))
        
        //self.addGestureRecognizer(pressGestureRecognizer)
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
    
    func handleSelectButtonPress(sender: UIButton!) {
        print("HIT THE MENU BUTTON")
        
        if (self.layer.borderWidth == 5){
            self.layer.borderWidth = 0
            btnSelected = false
        }else {
            self.layer.borderWidth = 5
            btnSelected = true
        }
    }
    
    func startRecording() {
        
        // Check if you are currently recording
        if(audioRecorder != nil && audioRecorder.isRecording) {
            finishRecording(success: true)
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
                
                //recordButton.setTitle("Tap to Stop", for: .normal)
            } catch {
                finishRecording(success: false)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        playerA = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        
        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
            
            //let path = Bundle.main.path(forResource: "recording1", ofType: "m4a")
            do {
                playAudioEngine()
                
            }
            print("ENDED OF ")
            
        } else {
            print("UNSUCCESSFUL RECORDING")
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
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
            playerA.play()
        } catch {
            print("Playing didn't work")
        }
        
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            print("DidFinish FALSE")
        } else {
            print("DidFinish TRUE")
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        print("TAPPED!")
        if(audioFileName != nil){
            if playerA.isPlaying {
                playerA.pause()
            } else {
                playerA.play()
            }
        }
    }
    /*
     
     func handlePress(sender: UILongPressGestureRecognizer) {
     if sender.state == UIGestureRecognizerState.began {
     // handle start of pressing
     print("Start press")
     startRecording()
     }
     else if sender.state == UIGestureRecognizerState.ended {
     // handle end of pressing
     print("End press")
     finishRecording(success: true)
     }
     }
     */
    /*
     func handleDoubleTap(sender: UITapGestureRecognizer) {
     print("DOUBLE TAP")
     if sender.state == .ended {
     print("UIGestureRecognizerStateEnded")
     //Do Whatever You want on End of Gesture
     }
     else if sender.state == .began {
     print("UIGestureRecognizerStateBegan.")
     //Do Whatever You want on Began of Gesture
     }
     }
     */
    
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
}
