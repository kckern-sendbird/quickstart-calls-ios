//
//  DialViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import SendBirdCalls

class DialViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var calleeIdTextField: UITextField!
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!   // For interaction with audio setting switch
    @IBOutlet weak var dialButtonCenterConstraint: NSLayoutConstraint!  // For interaction with keyboard
    
    @IBOutlet weak var audioMutedView: UIView!
    @IBOutlet weak var audioMutedSwitch: UISwitch!
    @IBOutlet weak var videoSwitch: UISwitch!
    
    var isMyAudioEnabled: Bool {
        return audioMutedSwitch.isOn
    }
    
    var isMyVideoEnabled: Bool { videoSwitch.isOn }
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calleeIdTextField.delegate = self
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
        
        self.setupUI()
    }
    
    func setupUI() {
        self.calleeIdTextField.placeholder = "Enter User ID You Want to Call"
        
        self.voiceCallButton.smoothAndWider()
        self.voiceCallButton.setTitle("Voice Call")
        self.voiceCallButton.isEnabled = false
        
        self.videoCallButton.smoothAndWider()
        self.videoCallButton.setTitle("Video Call")
        self.videoCallButton.isEnabled = false
        
        self.audioMutedView.alpha = 0.0
        self.textFieldBottomConstraint.constant = 16
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Voice", let voiceVC = segue.destination as? VoiceViewController, let call = sender as? DirectCall {
            voiceVC.isDialing = true
            voiceVC.call = call
        } else if segue.identifier == "Video", let videoVC = segue.destination as? VideoViewController, let call = sender as? DirectCall {
            videoVC.isDialing = true
            videoVC.call = call
        }
    }
    
    // MARK: Showing up Account
    @IBAction func didTapAccount(_ sender: Any) {
        performSegue(withIdentifier: "Account", sender: nil)
    }
}

// MARK: - User Interaction with SendBirdCall
extension DialViewController {
    
    @IBAction func didTapVoiceCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else { return }
        self.voiceCallButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: self.isMyAudioEnabled, isVideoEnabled: false)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: false, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async {
                self.voiceCallButton.isEnabled = true
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async {
                    self.alertError(message: "Failed to call\nError: \(String(describing: error?.localizedDescription))")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Voice", sender: call)
            }
        }
    }
    
    @IBAction func didTapVideoCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else { return }
        self.videoCallButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: self.isMyAudioEnabled, isVideoEnabled: self.isMyVideoEnabled)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: true, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async {
                self.videoCallButton.isEnabled = true
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async {
                    self.alertError(message: "Failed to call\nError: \(String(describing: error?.localizedDescription))")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Video", sender: call)
            }
        }
        dialParams.callOptions.isVideoEnabled = false
    }
}

// MARK: - Setting Up UI
extension DialViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        audioMutedView.alpha = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.filteredText, !text.isEmpty else { return false }
        return true
    }
    
    // MARK: When Keyboard Show
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameBegin = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else  { return }
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        let keyboardHeight = keyboardFrameBeginRect.size.height
        
        let bottomOfTextField = view.frame.maxY - calleeIdTextField.frame.maxY
        let safeArea = keyboardHeight + 8.0
        let gap = bottomOfTextField - safeArea
            
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            if bottomOfTextField < safeArea {
                
                self.textFieldBottomConstraint.constant = self.textFieldBottomConstraint.constant + gap
            }
            self.voiceCallButton.alpha = 0.0
            self.videoCallButton.alpha = 0.0
            self.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        var value: CGFloat = 16.0
        var hideMuteOptionView = true
        if let text = self.calleeIdTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            value = 200
            hideMuteOptionView = false
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.voiceCallButton.alpha = 1.0
            self.voiceCallButton.isEnabled = true
            self.videoCallButton.alpha = 1.0
            self.videoCallButton.isEnabled = true
            self.audioMutedView.alpha = hideMuteOptionView ? 0.0 : 1.0
            self.textFieldBottomConstraint.constant = value
            self.view.layoutIfNeeded()
        })
    }
}

