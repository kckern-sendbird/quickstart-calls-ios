//
//  AppDelegate+CXProviderDelegate.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import SendBirdCalls

extension AppDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        //
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // MARK: SendBirdCalls - SendBirdCall.getCall()
        AVAudioSession.default.update()

        guard SendBirdCall.getCall(forUUID: action.callUUID) != nil else {
            action.fail()
            return
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // MARK: SendBirdCalls - DirectCall.accept()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true)
        let acceptParams = AcceptParams(callOptions: callOptions)
        call.accept(with: acceptParams)
        
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        var viewController: UIViewController?
        if call.isVideoCall {
            viewController = storyboard.instantiateViewController(withIdentifier: "VideoViewController")
            guard let videoVC = viewController as? VideoViewController else { return }
            videoVC.call = call
            videoVC.isDialing = false
            
            if let topViewController = UIViewController.topViewController {
                topViewController.present(videoVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController = videoVC
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: "VoiceViewController")
            guard let voiceVC = viewController as? VoiceViewController else { return }
            voiceVC.call = call
            voiceVC.isDialing = false
            
            if let topViewController = UIViewController.topViewController {
                topViewController.present(voiceVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController = voiceVC
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        }
        // If there is termination: Failed to load VoiceViewController from Main.storyboard. Please check its storyboard ID")
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        try? AVAudioSession.sharedInstance().setActive(false)
        
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // For decline
        if call.endResult == .unknown {
            call.end()
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // MARK: SendBirdCalls - DirectCall.muteMicrophone / .unmuteMicrophone()
        action.isMuted ? call.muteMicrophone() : call.unmuteMicrophone()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) { }
}
