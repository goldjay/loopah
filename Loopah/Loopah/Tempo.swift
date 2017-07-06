//
//  Tempo.swift
//  Loopah
//
//  Created by Jay Steingold on 7/5/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

// Code taken fro Greg Cerveny Medium article 


import Foundation

struct Tempo {
    var bpm: Double
    func seconds(duration: Double = 0.25) -> Double {
        return 1.0 / self.bpm * 60.0 * 4.0 * duration
    }
}
