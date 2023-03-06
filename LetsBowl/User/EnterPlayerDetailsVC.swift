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
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playerDetailsVM: EnterPlayerDetailsViewModel = EnterPlayerDetailsViewModel()
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        self.title = "Enter Player Details"
        self.playerListTableView.isHidden = true
        self.playerName2TxtFld.isUserInteractionEnabled = false
        playerDetailsVM.getPlayerList()
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
