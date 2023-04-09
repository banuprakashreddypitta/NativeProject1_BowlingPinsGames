//
//  EnterPlayerDetailsVC.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 24/02/23.
//

import Foundation
import UIKit
import CoreData

class EnterPlayerDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playerName1TxtFld: UITextField!
    @IBOutlet weak var playerName2TxtFld: UITextField!
    @IBOutlet weak var playerListTableView: UITableView!
    @IBOutlet weak var fieldsBGView: UIView!
    @IBOutlet weak var fieldsBGViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var player1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var player2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playBtnHeightConstraint: NSLayoutConstraint!
    
    var bowlAnimateView: UIImageView!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playerDetailsVM: EnterPlayerDetailsViewModel = EnterPlayerDetailsViewModel()
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        self.title = "Enter Player Details"
        self.playerListTableView.isHidden = true
        self.playerName2TxtFld.isUserInteractionEnabled = false
        addBackgroundImage()
        setCornerRadius()
        addBlurEffectToFieldsView()
        self.hideTitleLabel(for: true)
        hideOrDisplayBtn(for: true)
        playerDetailsVM.getPlayerList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showfields()
    }
    
    // MARK: - IB actions
    
    @IBAction func playBtnTapped(_ sender: UIButton) {
        if let errorMessage = self.playerDetailsVM.validatePlayerNameFor(player1: self.playerName1TxtFld.text ?? "", player2: self.playerName2TxtFld.text ?? "") {
            displayAlertWith(title: errorMessage.0, message: errorMessage.1)
            return
        }
        let status = self.playerDetailsVM.savePlayerDetailsToDB(player1Name: self.playerName1TxtFld.text!, player2Name: self.playerName2TxtFld.text!)
        if let playerList = status.0 {
            loadPlayerVCWith(player: playerList)
        }
    }
    
    // MARK: - tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerDetailsVM.playerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerNameTableViewCell") as? PlayerNameTableViewCell
        let player = playerDetailsVM.playerList[indexPath.row]
        if let cell = cell {
            cell.playerNameLbl.text = player.playerName
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.playerName1TxtFld.isFirstResponder {
            self.playerName1TxtFld.text = self.playerDetailsVM.playerList[indexPath.row].playerName
            self.playerName1TxtFld.resignFirstResponder()
        }
        if self.playerName2TxtFld.isFirstResponder {
            self.playerName2TxtFld.text = self.playerDetailsVM.playerList[indexPath.row].playerName
            self.playerName2TxtFld.resignFirstResponder()
        }
    }
    
    // MARK: - textfield delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.playerListTableView.isHidden = false
        self.playerListTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.playerListTableView.isHidden = true
    }
    
    // MARK: - helper functions
    
    func addBackgroundImage() {
        bowlAnimateView = UIImageView(frame: self.view.frame)
        self.view.addSubview(bowlAnimateView)
        bowlAnimateView.contentMode = .scaleToFill
        let image = UIImage(named: AppConstants.bgImage)
        self.bowlAnimateView.image = image
        self.view.sendSubviewToBack(self.bowlAnimateView)
    }
    
    func showfields() {
        UIView.animate(withDuration: AppConstants.animationDuration, animations: { [weak self] in
            self?.hideOrDisplayBtn(for: false)
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.hideTitleLabel(for: false)
            self?.fieldsBGView.dropShadow(color: AppConstants.shawdowColor, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
        })
    }
    
    func addBlurEffectToFieldsView() {
        fieldsBGView.addBlurEffect()
    }
    
    func setCornerRadius() {
        fieldsBGView.layer.cornerRadius = 10
        playerName1TxtFld.layer.cornerRadius = 5.0
        playerName2TxtFld.layer.cornerRadius = 5.0
        playBtn.layer.cornerRadius = 5.0
    }
    
    func hideOrDisplayBtn(for hide: Bool) {
        let fieldHeight: CGFloat = hide ? 0 : 40
        fieldsBGViewConstraint.constant = hide ? 0 : 180
        player1HeightConstraint.constant = fieldHeight
        player2HeightConstraint.constant = fieldHeight
        playBtnHeightConstraint.constant = fieldHeight
    }
    
    func hideTitleLabel(for hide: Bool) {
        self.playBtn.titleLabel?.isHidden = hide
    }
    
    func loadPlayerVCWith(player: [Player]) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let playGameVC = storyBoard.instantiateViewController(withIdentifier: "PlayGameVC") as! PlayGameVC
        playGameVC.player = player
        self.navigationController?.pushViewController(playGameVC, animated: true)
    }
    
    func displayAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
}
