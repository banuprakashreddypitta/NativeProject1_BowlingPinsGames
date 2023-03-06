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
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playerList: [Player] = []
    
    // MARK: - view life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerList()
        checkAndCreatebotPlayer()
        if playerList.count == 0 {
            topScoresBtn.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - IB actions
    
    @IBAction func startGameBtnTapped(_ sender: UIButton) {
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
        fatalError("Exiting application")
    }
    
    // MARK: - helper functions
    
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
