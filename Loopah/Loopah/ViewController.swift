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
        
        /*
         let button1  = UIButton(type:  .custom)
         button1.frame = CGRect(x:100, y:50, width:50, height:50)
         if let image = UIImage(named:"circle.png") {
         button1.setImage(image, for: .normal)
         }
         self.view.addSubview(button1)
         */
        /*
        let button2  = playButton!
        button2.shapeColor = UIColor.red
        button2.buttonShape = Shape.Triangle
        button2.frame = CGRect(x:190, y:30, width:30, height:30)
        if let image = drawCustomImage(size:button2.frame.size,imageShape: button2.buttonShape,color:button2.shapeColor) {
            button2.setImage(image, for: .normal)
        }
        button2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        self.view.addSubview(button2)
        */
        
        /*
         let button3  = ShapeButton(type:  .custom)
         button3.buttonShape = Shape.Circle
         button3.shapeColor = UIColor.green
         button3.frame = CGRect(x:190, y:30, width:30, height:30)
         if let image = drawCustomImage(size:button3.frame.size,imageShape: button3.buttonShape,color:button3.shapeColor) {
         button3.setImage(image, for: .normal)
         }
         self.view.addSubview(button3)
         */
    }
    
    func drawCustomImage(size: CGSize,imageShape:Shape,color:UIColor) -> UIImage? {
        // Setup our context
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Setup complete, do drawing here
        context.setStrokeColor(color.cgColor) //UIColor.red.cgColor
        context.setLineWidth(1)
        
        // Would draw a border around the rectangle
        // context.stroke(bounds)
        
        context.beginPath()
        if imageShape == Shape.Triangle {
            context.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            context.addLine(to: CGPoint(x: bounds.maxX/2, y: bounds.minY))
            context.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        } else {
            context.addEllipse(in: bounds)
        }
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func playFile(_ sender: AnyObject) {
        
        //let path = Bundle.main.path(forResource: "recording1.m4a", ofType:nil)!
        //let url = URL(fileURLWithPath: path)
        
        
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
            /*
             if let image = drawCustomImage(size:sender.frame.size,imageShape: sender.buttonShape,color:sender.shapeColor) {
             sender.setImage(image, for: .normal)
             }
             */
        })
        view.layoutIfNeeded()
    }
    
    
}

