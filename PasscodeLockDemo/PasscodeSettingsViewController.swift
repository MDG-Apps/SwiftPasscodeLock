//
//  PasscodeSettingsViewController.swift
//  PasscodeLockDemo
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeSettingsViewController: UITableViewController {
    
    var InSetup = false
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if InSetup {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        }
        self.title = "Passcode-Sperre".localized()
    }
    
    @IBAction func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.textAlignment = .Center
        let hasPasscode = configuration.repository.hasPasscode
        switch indexPath.row {
        case 0:
            if hasPasscode {
                cell.textLabel?.text = "Code-Sperre deaktivieren".localized()
            } else {
                cell.textLabel?.text = "Code-Sperre aktivieren".localized()
            }
        default:
            cell.textLabel?.text = "Code ändern".localized()
            cell.userInteractionEnabled = hasPasscode
            if !hasPasscode {
                cell.textLabel?.textColor = UIColor.grayColor()
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hasPasscode = configuration.repository.hasPasscode
        switch indexPath.row {
        case 0:
            let passcodeVC: PasscodeLockViewController
            if !hasPasscode {
                passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            } else {
                
                passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
                
                passcodeVC.successCallback = { lock in
                    
                    lock.repository.deletePasscode()
                }
            }
            presentViewController(passcodeVC, animated: true, completion: nil)
        default:
            let repo = UserDefaultsPasscodeRepository()
            let config = PasscodeLockConfiguration(repository: repo)
            
            let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
            
            presentViewController(passcodeLock, animated: true, completion: nil)
        }
    }
    
    func updatePasscodeView() {
        tableView.reloadData()
    }
}
