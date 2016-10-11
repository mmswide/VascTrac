//
//  AudioManager.swift
//  Vasctrac
//
//  Created by Developer on 5/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: UIView {

    static let sharedManager = AudioManager()

    private var player: AVAudioPlayer?
    
    func playSound(withName soundName: String, withExtension soundExtension: String) {
        let url = NSBundle.mainBundle().URLForResource(soundName, withExtension: soundExtension)!
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }

}
