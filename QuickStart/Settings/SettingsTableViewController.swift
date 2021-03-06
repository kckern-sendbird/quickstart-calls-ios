//
//  SettingsTableViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var userProfileImageView: UIImageView! {
        didSet {
            let profile = UserDefaults.standard.user.profile
            self.userProfileImageView.setImage(urlString: profile)
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            self.usernameLabel.text = UserDefaults.standard.user.name
        }
    }
    @IBOutlet weak var userIdLabel: UILabel! {
        didSet {
            self.userIdLabel.text = UserDefaults.standard.user.id
        }
    }
    
    enum CellRow: Int {
        case applnfo = 1
        case signOut = 2
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch CellRow(rawValue: indexPath.row) {
        case .applnfo:
            self.performSegue(withIdentifier: "appInfo", sender: nil)
        case .signOut:
            let alert = UIAlertController(title: "Do you want to sign out?",
                                          message: "If you sign out, you cannot receive any calls.",
                                          preferredStyle: .alert)
            
            let actionSignOut = UIAlertAction(title: "Sign Out", style: .default) { _ in
                // MARK: Sign Out
                self.signOut()
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(actionSignOut)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        default: return
        }
    }
}

// MARK: - SendBirdCall Interaction
extension SettingsTableViewController {
    func signOut() {
        guard let token = UserDefaults.standard.voipPushToken else { return }
        
        // MARK: SendBirdCall Deauthenticate
        SendBirdCall.deauthenticate(voipPushToken: token) { error in
            UserDefaults.standard.clear()
            guard error == nil else { return }
        }
    }
}

