//
//  WalkTillStationaryContentView.swift
//  Vasctrac
//
//  Created by Developer on 3/25/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import AVFoundation

class WalkTillStationaryContentView: UIView {
    
    // xib loading
    var view:UIView!
    var nibName:String = "WalkTillStationaryContentView"
    
    var playerLayer: AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view)
        
        let videoURL = NSBundle.mainBundle().URLForResource("walkinganimation", withExtension: "m4v")!
        let player = AVPlayer(URL: videoURL)  
        playerLayer = AVPlayerLayer(player: player)  
        self.layer.addSublayer(playerLayer)
        player.play()
        player.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(videoPlayerItemDidReachEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
        self.heartImageView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let playerLayer = playerLayer {
            let heartImageViewHeight = self.heartImageView.bounds.size.height
            playerLayer.frame = CGRect(x: 0, y: self.heartImageView.frame.origin.y - (heartImageViewHeight * 0.3), width: self.bounds.size.width, height: heartImageViewHeight * 1.3)
        }
    }
    
    func videoPlayerItemDidReachEnd(notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seekToTime(kCMTimeZero)
        }
    }
    
    
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopButton: BorderButton!
    
    @IBOutlet weak var output: UILabel!
    
    var previousAlpha : Int = 0
}
