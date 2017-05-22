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
    var audioPlayer: AVAudioPlayer!
    
    var audioEngine: AVAudioEngine!
    var avNode: AVAudioPlayerNode!
    var file: AVAudioFile!
    

    var audioFileName: URL? = nil
    var btnSelected: Bool = false
    
    var distorsionVal: Float = 0
        /*
     
        */
    
    var pitchVal: Float = 0 {
        didSet {
            pitchUnit.pitch = pitchVal
        }
    }
    var reverbVal: Float = 0 {
        didSet {
            print("YOU SET THE VAL!")
            avNode.stop()
            reverbUnit.wetDryMix = reverbVal
            print(reverbUnit.wetDryMix)
            
            //avNode.scheduleFile(file, at: nil, completionHandler: nil)
            
            avNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            // Start the audio engine
            audioEngine.prepare()
            do{
            try audioEngine.start()
            avNode.play()
            }catch{
                print("Couldn't play")
            }
        }
    }
        
    
    
    let pitchUnit = AVAudioUnitTimePitch()
    let reverbUnit = AVAudioUnitReverb()
    let distortionUnit = AVAudioUnitDistortion()
    
    var buffer: AVAudioPCMBuffer!
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        let btn = UIButton(frame: CGRect(x: 100, y: 0, width: 50, height: 50))
        btn.backgroundColor = UIColor.red
        btn.layer.zPosition = 10
        btn.addTarget(self, action: #selector(handleSelectButtonPress(sender:)), for: .touchUpInside)
        addSubview(btn)
        
        // Set gesture recognizers
        
        let buttonTapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(sender:)))
        
        self.addGestureRecognizer(pressGestureRecognizer)
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
        audioFileName = getDocumentsDirectory().appendingPathComponent("recording\(self.tag).m4a")
        
        print(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        avNode = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        
        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
            
            //let path = Bundle.main.path(forResource: "recording1", ofType: "m4a")
            do {
                playAudioEngine()
                
                /*
                playing = true
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileName!)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
 
            */
                
            } catch {
                print(error)
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
            
            // This is a reverb with a cathedral preset. It's nice and ethereal
            // You're also setting the wetDryMix which controls the mix between the effect and the
            // original sound.
            
            reverbUnit.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
            reverbUnit.wetDryMix = 0
            
            // This is a distortion with a radio tower preset which works well for speech
            // As distortion tends to be quite loud you're setting the wetDryMix to only 25
            
            distortionUnit.loadFactoryPreset(AVAudioUnitDistortionPreset.speechCosmicInterference)
            distortionUnit.wetDryMix = 50
            
            pitchUnit.pitch = 2400
            pitchUnit.rate = 32
            
            // Attach the four nodes to the audio engine
            audioEngine.attach(avNode)
            audioEngine.attach(reverbUnit)
            audioEngine.attach(distortionUnit)
            audioEngine.attach(pitchUnit)
            
            // Connect playerA to the reverb
            audioEngine.connect(avNode, to: reverbUnit, format: buffer.format)
            // Connect the reverb to the mixer
            audioEngine.connect(reverbUnit, to: audioEngine.mainMixerNode, format: buffer.format)
            // Connect the distortion to the mixer
            audioEngine.connect(distortionUnit, to: audioEngine.mainMixerNode, format: buffer.format)
            // Connect the pitch to the mixer
            audioEngine.connect(pitchUnit, to: audioEngine.mainMixerNode, format: buffer.format)
            
            // Schedule sound to play on buffer in a loop
            avNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            // Start the audio engine
            audioEngine.prepare()
            try audioEngine.start()
            avNode.play()
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
        
        if avNode.isPlaying {
            avNode.pause()
            
        } else {
            // If there is a file, play
            if((audioFileName) != nil){
            avNode.play()
            //audioPlayer.numberOfLoops = -1
            //audioPlayer.play()
            
            }
        }
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("LONG PRESS")
        
    }
    
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
}
