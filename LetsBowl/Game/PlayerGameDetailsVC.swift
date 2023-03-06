//
//  PlayerGameDetailsVC.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 25/02/23.
//

import Foundation
import UIKit
import CoreData

class PlayerGameDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var gameDetailsTblView: UITableView!
    var sections: [Section] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dateFormatter = DateFormatter()
    
    // MARK: - view life cycles
    
    override func viewDidLoad() {
        self.title = "Player History"
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        sections = sortElementsByDate()
    }
    
    // MARK: - tableview methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  dateFormatter.string(from: sections[section].title)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameDetailsTableViewCell") as? GameDetailsTableViewCell
        if let cell = cell {
            let gameDetails = sections[indexPath.section].games[indexPath.row]
            cell.playerNameLbl.text = "Player: \(gameDetails.player?.playerName ?? "")"
            cell.scoreLbl.text = "Score: \(gameDetails.score)"
            cell.gamedTypeLbl.text = "Game type: " + (gameDetails.gameType ?? "")
            if gameDetails.gameType == "multiple" {
                cell.gameStatus.isHidden = false
                cell.gameStatus.text = gameDetails.status ? "Won" : "Lost"
            } else {
                cell.gameStatus.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - date helper
    
    func sortElementsByDate() -> [Section] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameData")
        do {
            let gameDataList = try managedContext.fetch(fetchRequest) as? [GameData]
            if let gameDataList = gameDataList {
                let grouped = Dictionary(grouping: gameDataList) { $0.time }
                let sections = grouped.map { Section(title: $0.key ?? Date(), games: (($0.value.count >= 20) ? Array(($0.value.sorted { ($1.score < $0.score)}[0..<10].filter {$0.player?.playerName?.lowercased() != "bot"})) : ($0.value.sorted {($1.score < $0.score)}.filter {$0.player?.playerName?.lowercased() != "bot"})))}
                return sections
            }
        } catch {
           print("error in fetching game data")
        }
       return []
    }
    
}


struct Section {
    let title: Date
    let games: [GameData]
}
