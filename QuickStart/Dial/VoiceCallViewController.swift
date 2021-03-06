//
//  VoiceCallViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import AVKit
import CallKit
import MediaPlayer
import SendBirdCalls

class VoiceCallViewController: UIViewController, DirectCallDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            let profileURL = self.call.remoteUser?.profileURL
            self.profileImageView.setImage(urlString: profileURL)
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var callTimerLabel: UILabel!
    
    // Notify muted state
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var mutedStateLabel: UILabel!
    
    var call: DirectCall!
    var isDialing: Bool?
    
    var callTimer: Timer?
    
    let callController = CXCallController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call.delegate = self
        
        self.setupUI()
        self.setupAudioOutputButton()
        self.updateRemoteAudio(isEnabled: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isDialing == true {
            guard let calleeId = self.call.remoteUser?.userId else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.startCXCall(to: calleeId)
        }
    }
    
    // MARK: - IBActions
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        call.end()
        self.requestEndTransaction(of: call)
    }
    
    // MARK: - Basic UI
    func setupUI() {
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        self.callTimerLabel.text = "Calling..."
        self.nameLabel.text = self.call.remoteUser?.userId
        self.mutedStateLabel.text = "\(self.call.remoteUser?.userId ?? "Remote user") is on mute"

        // Local Info
        self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
    }
    
    func setupEndedCallUI() {
        self.callTimer?.invalidate()    // Main thread
        self.callTimer = nil
        self.callTimerLabel.text = "Call ended"
        
        self.endButton.isHidden = true
        self.speakerButton.isHidden = true
        self.muteAudioButton.isHidden = true
        
        self.mutedStateImageView.isHidden = true
        self.mutedStateLabel.isHidden = true
    }
    
    // MARK: - CallKit Methods
    func startCXCall(to calleeId: String) {
        
        let handle = CXHandle(type: .generic, value: calleeId)
        
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - Start Call")
    }
    
    func requestEndTransaction(of call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - End Call")
    }
}

// MARK: - SendBirdCalls: Audio Features
extension VoiceCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        self.muteAudioButton.setBackgroundImage(UIImage(named: isEnabled ? "btnAudioOffSelected" : "btnAudioOff"), for: .normal)
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isEnabled: Bool) {
        self.mutedStateImageView.isHidden = isEnabled
        self.mutedStateLabel.isHidden = isEnabled
    }
}

// MARK: - SendBirdCalls: Audio Output
extension VoiceCallViewController {
    func setupAudioOutputButton() {
        let width = self.speakerButton.frame.width
        let height = self.speakerButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

    
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        self.customize(routePickerView)
        self.speakerButton.addSubview(routePickerView)
    }
    
    func customize(_ routePickerView: UIView) {
        if #available(iOS 11.0, *) {
            guard let routePickerView = routePickerView as? AVRoutePickerView else { return }
            routePickerView.activeTintColor = .clear
            routePickerView.tintColor = .clear
        } else {
            guard let volumeView = routePickerView as? MPVolumeView else { return }
            
            volumeView.showsVolumeSlider = false
            volumeView.setRouteButtonImage(nil, for: .normal)
            volumeView.routeButtonRect(forBounds: volumeView.frame)
        }
    }
}

// MARK: - SendBirdCalls: DirectCall duration
extension VoiceCallViewController {
    func activeTimer() {
        self.callTimerLabel.text = "00:00"
        
        // Main thread
        self.callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let duration = Double(self.call.duration)
            
            let convertedTime = Int(duration / 1000)
            let hour = Int(convertedTime / 3600)
            let minute = Int(convertedTime / 60) % 60
            let second = Int(convertedTime % 60)
            
            // update UI
            let secondText = second < 10 ? "0\(second)" : "\(second)"
            let minuteText = minute < 10 ? "0\(minute)" : "\(minute)"
            let hourText = hour == 0 ? "" : "\(hour):"
            
            self.callTimerLabel.text = "\(hourText)\(minuteText):\(secondText)"
            
            // Timer Invalidate
            if self.call.endedAt != 0, timer.isValid {
                timer.invalidate()
                self.callTimer = nil
            }
        }
    }
}

// MARK: - SendBirdCalls: DirectCallDelegate
// Delegate methods are executed on Main thread

extension VoiceCallViewController: DirectCallDelegate {
    // MARK: Required Methods
    func didConnect(_ call: DirectCall) {
        self.activeTimer()      // call.duration
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
    
    func didEnd(_ call: DirectCall) {
        self.setupEndedCallUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        self.requestEndTransaction(of: call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.callTimerLabel.text = "Connecting..."
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard !call.isEnded else { return }
        guard let output = session.currentRoute.outputs.first else { return }
        
        let outputType = output.portType
        let outputName = output.portName
        
        // Customize images
        var imageName = "btnSpeaker"
        switch outputType {
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE: imageName = "btnBluetoothSelected"
        case .builtInSpeaker: imageName = "btnSpeakerSelected"
        default: imageName = "btnSpeaker"
        }
        
        self.speakerButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
        print("[QuickStart] Audio Route has been changed to \(outputName)")
    }
}
