//
//  GameSettingsVC.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 06/04/23.
//

import Foundation
import UIKit

class GameSettingsVC: UIViewController {
    
    @IBOutlet weak var useGyroSwitch: UISwitch!
    @IBOutlet weak var useAcceleroSwitch: UISwitch!
    @IBOutlet weak var settingsBgView: UIView!
    
    var bowlAnimateView: UIImageView!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Game settings"
        addBlurEffectToBtnsView()
        addBackgroundImage()
        useGyroSwitch.isOn = UserDefaults.standard.useGyroToPosition
        useAcceleroSwitch.isOn = UserDefaults.standard.useAcceleroToStrike
    }
    
    // MARK: - switch actions
    
    @IBAction func gyroValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.useGyroToPosition = sender.isOn
    }
    
    @IBAction func acceleroValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.useAcceleroToStrike = sender.isOn
    }
    
    @IBAction func closeGameSettings(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - helper functions
    
    func addBlurEffectToBtnsView() {
        settingsBgView.layer.cornerRadius = AppConstants.bgViewCornerRadius
        settingsBgView.clipsToBounds = true
        settingsBgView.addBlurEffect()
        settingsBgView.dropShadow(color: AppConstants.shawdowColor, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
    }
    
    func addBackgroundImage() {
        bowlAnimateView = UIImageView(frame: self.view.frame)
        self.view.addSubview(bowlAnimateView)
        bowlAnimateView.contentMode = .scaleToFill
        let image = UIImage(named: AppConstants.bgImage)
        self.bowlAnimateView.image = image
        self.view.sendSubviewToBack(self.bowlAnimateView)
    }
}
