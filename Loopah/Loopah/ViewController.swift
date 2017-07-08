//
//  ViewController.swift
//  Loopah
//
//  Created by Jay Steingold on 5/1/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

import UIKit
import AVFoundation

enum Shape {
    case Triangle, Circle
}

class ShapeButton : UIButton
{
    var shapeColor:UIColor!
    var buttonShape:Shape!
}

class ViewController: UIViewController {
    
    var mySound: AVAudioPlayer!
    
    @IBOutlet weak var playButton: ShapeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let margins = view.layoutMarginsGuide
        
        let colorArr = [UIColor.blue, UIColor.red, UIColor.cyan, UIColor.green]
        
        var buttonArr = createButtons(dimensions: 150, color: colorArr)
        
        // Create grid method, takes in array of buttons and creates even grid (MUST have a square root)
        
        // If buttons.count is
        
        
        let topStackView = UIStackView(arrangedSubviews: [buttonArr[0], buttonArr[1]])
        topStackView.axis = .horizontal
        topStackView.distribution = .fillEqually
        topStackView.alignment = .fill
        topStackView.spacing = 20
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomStackView = UIStackView(arrangedSubviews: [buttonArr[2], buttonArr[3]])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.alignment = .fill
        bottomStackView.spacing = 20
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        let offset = -view.frame.size.height / 4
        
        stackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: offset).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pitchChanged(_ sender: UISlider) {
        sender.isContinuous = false // stops continuous updating
        
        for case let btn as AudioButton in self.view.subviews {
            if(btn.btnSelected){
                btn.pitchVal = sender.value
            }
        }
    }
    
    @IBAction func reverbChanged(_ sender: UISlider) {
        sender.isContinuous = false // stops continuous updating
        print(sender.value)
        
        for case let btn as AudioButton in self.view.subviews {
            if(btn.btnSelected){
                btn.reverbVal = sender.value
            }
        }
    }
    
    @IBAction func distorsionChanged(_ sender: UISlider) {
        sender.isContinuous = false // stops continuous updating
        
        for case let btn as AudioButton in self.view.subviews {
            if(btn.btnSelected){
                btn.distorsionVal = sender.value
            }
        }
        
    }
    
    @IBAction func speedChanged(_ sender: UISlider) {
        sender.isContinuous = false // stops continuous updating
        
        for case let btn as AudioButton in self.view.subviews {
            if(btn.btnSelected){
                btn.playBackVal = sender.value
            }
        }
    }
    
    @IBAction func handlePlayButton(_ sender: ShapeButton) {
        
        UIView.animate(withDuration: 1.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            sender.layer.cornerRadius = 50
            print("ANIMATING CHANGE")
            
        })
        view.layoutIfNeeded()
    }
    
    func createButtons(dimensions: Int, color: [UIColor]) -> [UIButton] {
        
        var buttonArr = [UIButton]()
        
        for i in 0..<color.count {
            let b = AudioButton(dimensions: dimensions, activeColor: color[i])
            let widthConstraint = NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150)
            let heightConstraint = NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150)
            b.addConstraint(widthConstraint)
            b.addConstraint(heightConstraint)
            b.tag = i + 1
            b.setTitle(String(b.tag), for: .normal)
            
            buttonArr.append(b)
        }
        return buttonArr
    }
}

