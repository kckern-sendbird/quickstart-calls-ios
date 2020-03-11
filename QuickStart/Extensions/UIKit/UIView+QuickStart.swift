//
//  UIView+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/09.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIView {
    func embed(_ videoView: SendBirdVideoView) {
        self.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        self.layoutIfNeeded()
    }
}
