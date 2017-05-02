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
    
    var audioFileName: URL? = nil
    var playing: Bool = false
    var currTime: TimeInterval = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.loadRecordingUI()
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
    
    func loadRecordingUI() {
        let recordButton = self
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        /*
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
        */
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
        
        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
            
            //let path = Bundle.main.path(forResource: "recording1", ofType: "m4a")
            do {
                
                playing = true
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileName!)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
                
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
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
            print("DidFinish FALSE")
        } else {
            print("DidFinish TRUE")
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        if playing == true {
            currTime = audioPlayer.currentTime
            audioPlayer.pause()
            playing = false
        } else {
            
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            playing = true
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
