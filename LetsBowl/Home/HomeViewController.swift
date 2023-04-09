//
//  HomeViewController.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 06/03/23.
//

import Foundation
import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var startGameBtn: UIButton!
    @IBOutlet weak var topScoresBtn: UIButton!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var btnsBGView: UIView!
    @IBOutlet weak var btnsBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startGameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topScoresHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gameTypeBgviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gameTypeBgView: UIView!
    @IBOutlet weak var gameSettingsBtn: UIButton!
    
    var bowlAnimateView: UIImageView!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playerList: [Player] = []
    let cornerRadius = 5.0
    var gameSound: PlayGameSounds = PlayGameSounds()
    
    // MARK: - view life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerList()
        checkAndCreatebotPlayer()
        if playerList.count == 0 {
            topScoresBtn.isUserInteractionEnabled = false
        }
        setCornerRadius()
        addBlurEffectToBtnsView()
        hideTitleLabel(for: true)
        hideOrDisplayBtn(for: true)
        loadAnimateGif()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameSound.startPlayback(with: .gamebgm)
        gameSound.repeatPlayback()
    }
    
    // MARK: - IB actions
    
    @IBAction func startGameBtnTapped(_ sender: UIButton) {
        gameSound.stopPlayback()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let playGameVC = storyBoard.instantiateViewController(withIdentifier: "EnterPlayerDetailsVC") as! EnterPlayerDetailsVC
        self.navigationController?.pushViewController(playGameVC, animated: true)
    }
    
    @IBAction func topScoreBtnTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let gameDetailsVC = storyBoard.instantiateViewController(withIdentifier: "PlayerGameDetailsVC") as! PlayerGameDetailsVC
        self.navigationController?.pushViewController(gameDetailsVC, animated: true)
    }
    
    @IBAction func exitBtnTapped(_ sender: UIButton) {
        gameSound.stopPlayback()
        fatalError("Exiting application")
    }
    
    @IBAction func gameSettingsTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let gameSettingsVC = storyBoard.instantiateViewController(withIdentifier: "GameSettingsVC") as! GameSettingsVC
        self.navigationController?.present(gameSettingsVC, animated: true)
    }
    
    // MARK: - helper functions
    
    func setCornerRadius() {
        btnsBGView.layer.cornerRadius = AppConstants.bgViewCornerRadius
        btnsBGView.clipsToBounds = true
        startGameBtn.layer.cornerRadius = AppConstants.placeHolderCornerRadius
        topScoresBtn.layer.cornerRadius = AppConstants.placeHolderCornerRadius
        exitBtn.layer.cornerRadius = AppConstants.placeHolderCornerRadius
        gameTypeBgView.layer.cornerRadius = AppConstants.bgViewCornerRadius
        gameTypeBgView.clipsToBounds = true
        gameSettingsBtn.layer.cornerRadius = AppConstants.placeHolderCornerRadius
    }
    
    func addBlurEffectToBtnsView() {
        btnsBGView.addBlurEffect()
        gameTypeBgView.addBlurEffect()
    }
    
    func hideOrDisplayBtn(for hide: Bool) {
        let fieldHeight: CGFloat = hide ? 0 : 34
        btnsBgHeightConstraint.constant = hide ? 0 : 184
        startGameHeightConstraint.constant = fieldHeight
        topScoresHeightConstraint.constant = fieldHeight
        exitHeightConstraint.constant = fieldHeight
        gameTypeBgviewHeightConstraint.constant = hide ? 0 : 103
    }
    
    func hideTitleLabel(for hide: Bool) {
        self.startGameBtn.titleLabel?.isHidden = hide
        self.topScoresBtn.titleLabel?.isHidden = hide
        self.exitBtn.titleLabel?.isHidden = hide
    }
    
    func loadAnimateGif() {
        bowlAnimateView = UIImageView.fromGif(frame: self.view.frame, resourceName: "bowl_animation")
        self.view.addSubview(bowlAnimateView)
        bowlAnimateView.contentMode = .scaleToFill
        bowlAnimateView.startAnimating()
        self.perform(#selector(stopAnimateGif), with: nil, afterDelay: 3.0)
    }
    
    @objc func stopAnimateGif() {
        self.bowlAnimateView.stopAnimating()
        self.bowlAnimateView.animationImages = nil
        self.updateImage()
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: AppConstants.animationDuration, animations: { [unowned self] in
                hideOrDisplayBtn(for: false)
                self.view.layoutIfNeeded()
            }, completion: { [unowned self] _ in
                self.hideTitleLabel(for: false)
                self.btnsBGView.dropShadow(color: AppConstants.shawdowColor, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
                self.gameTypeBgView.dropShadow(color: AppConstants.shawdowColor, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
            })
        }
    }
    
    func updateImage() {
        let image = UIImage(named: AppConstants.bgImage)
        self.bowlAnimateView.image = image
        self.view.sendSubviewToBack(self.bowlAnimateView)
    }
    
    func getPlayerList() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
            let playerList = try managedContext.fetch(fetchRequest) as? [Player]
            if let playerList = playerList {
                self.playerList = playerList
            }
        } catch {
            print("exception in fetching player list")
        }
    }
    
    func checkAndCreatebotPlayer() {
        let player = self.playerList.filter { ($0.playerName?.lowercased() == "bot")}
        if player.count == 0 {
            do {
                let botPlayer = NSEntityDescription.insertNewObject(forEntityName: "Player", into: managedContext) as? Player
                botPlayer?.playerName = "bot"
                botPlayer?.playerId = UUID()
                try managedContext.save()
            } catch {
                print("exception in saving bot player:: \(error.localizedDescription)")
            }
        }
    }
    
    
}
