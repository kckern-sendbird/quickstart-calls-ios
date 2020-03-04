//
//  UIImageView+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIImageView {
    func rounding() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func border() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.lightPurple.cgColor
    }
    
    func setImage(urlString: String?) {
        guard let urlString = urlString,
            let profileURL = URL(string: urlString) else { return }
        guard let data = try? Data(contentsOf: profileURL) else { return }
        guard let image = UIImage(data: data) else { return }
        self.image = image
    }
}

extension UIImage {
    static var mutedAudioImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "mic.slash.fill")
            } else {
                return UIImage(named: "icon_audio_mute")
            }
        }
    }
    
    static var unmutedAudioImage: UIImage? {
        get {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "mic.fill")
            } else {
                return UIImage(named: "icon_audio_unmute")
            }
        }
    }
    
    static var stopVideoImage: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "video.fill")
        } else {
            return UIImage(named: "icon_video_stop")
        }
    }
    
    static var startVideoImage: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "video.slash.fill")
        } else {
            return UIImage(named: "icon_video_start")
        }
    }
}
