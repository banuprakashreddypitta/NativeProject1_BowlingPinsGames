//
//  EnterPlayerDetailsViewModel.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 05/03/23.
//

import Foundation
import UIKit
import CoreData

class EnterPlayerDetailsViewModel {
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playerList: [Player] = []
    var fullPlayList: [Player] = []
    var selectedPlayerList: [Player] = []
    let duplicatePlayerErrTitle = "Player Exist"
    let duplicatePlayerErrMessage = "A player with same name already selected. Please enter different name"
    let invalidPlayerErrTitle = "Invalid player name"
    let invalidPlayerErrMessage = "Please enter player name as per place holder instructions"
    
    func getPlayerList() {
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
            let playerList = try managedContext.fetch(fetchRequest) as? [Player]
            if let playerList = playerList {
                self.fullPlayList = playerList
                self.playerList = playerList.filter { $0.playerName?.lowercased() != "bot"}
            }
        } catch {
            print("exception in fetching player list")
        }
    }
        
    
    func validatePlayerNameFor(player1: String, player2: String) -> (String, String)? {
        if player1.isEmpty || player1.count > 10 {
            return (invalidPlayerErrTitle, invalidPlayerErrMessage)
        }
        if player1.lowercased() == player2.lowercased() {
            return (duplicatePlayerErrTitle, duplicatePlayerErrMessage)
        }
        return nil
    }
    
    func savePlayerDetailsToDB(player1Name: String, player2Name: String) -> ([Player]?,Bool) {
        let player1 = playerList.filter { ($0.playerName?.lowercased() == player1Name.lowercased())}
        let player2 = fullPlayList.filter { ($0.playerName?.lowercased() == "bot")}
        var firstPlayer: Player?
        var secondPlayer: Player?
        do {
            if player1.count > 0 {
                firstPlayer = player1[0]
            } else {
                firstPlayer = NSEntityDescription.insertNewObject(forEntityName: "Player", into: managedContext) as? Player
                firstPlayer?.playerName = player1Name
                firstPlayer?.playerId = UUID()
            }
            if player2.count > 0 {
                secondPlayer = player2[0]
            } else {
                secondPlayer = NSEntityDescription.insertNewObject(forEntityName: "Player", into: managedContext) as? Player
                secondPlayer?.playerName = "bot"
                secondPlayer?.playerId = UUID()
            }
            try managedContext.save()
        } catch {
            print("exception in saving player:: \(error.localizedDescription)")
            return (nil, false)
        }
        return ([firstPlayer!, secondPlayer!], true)
    }
}
