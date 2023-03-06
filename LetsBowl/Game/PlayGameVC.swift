//
//  PlayGameVC.swift
//  LetsBowl
//
//  Created by pitta, Banu on 24/02/23.
//

import Foundation
import UIKit
import CoreData

class PlayGameVC: UIViewController {
    
    @IBOutlet weak var pinBgView: UIView!
    @IBOutlet weak var pin10: UIImageView!
    @IBOutlet weak var pin9: UIImageView!
    @IBOutlet weak var pin8: UIImageView!
    @IBOutlet weak var pin7: UIImageView!
    @IBOutlet weak var pin6: UIImageView!
    @IBOutlet weak var pin5: UIImageView!
    @IBOutlet weak var pin4: UIImageView!
    @IBOutlet weak var pin3: UIImageView!
    @IBOutlet weak var pin2: UIImageView!
    @IBOutlet weak var pin1: UIImageView!
    @IBOutlet weak var striker: UIImageView!
    var animateCount = 0
    
    var player: [Player]!
    var panGesture = UIPanGestureRecognizer()
    let friction: CGFloat = 0.4;
    var done = false;
    var pinArray: [UIImageView] = []
    var pinCoordinates: [PinCoordinateModel] = []
    let dateFormatter = DateFormatter()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var strikerPreviousPosition : CGRect?
    var playGameViewModel: PlayGameViewModel = PlayGameViewModel()
    var yCoord: [CGFloat] = []
    var xCoord: [CGFloat] = []
    
    // MARK: - view life cycles
    
    override func viewDidLoad() {
        self.title = "Play Game"
        dateFormatter.dateFormat = "dd-MM-yyyy"
        addBarButtonItems()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        striker.isUserInteractionEnabled = true
        striker.addGestureRecognizer(panGesture)
        self.playGameViewModel.updateCurrentPlayerList(with: player)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addCoordinates()
        if self.strikerPreviousPosition == nil {
            self.strikerPreviousPosition = self.striker.frame
        }
    }
    
    func addBarButtonItems() {
        let btnLeft: UIButton = UIButton()
        btnLeft.setTitle(self.playGameViewModel.leftBarBtnTitle, for: .normal)
        btnLeft.addTarget(self, action: #selector(loadPlayerHistory), for: UIControl.Event.touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: btnLeft)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let btnRight: UIButton = UIButton()
        btnRight.setTitle(self.playGameViewModel.rightBarBtnTitle, for: .normal)
        btnRight.addTarget(self, action: #selector(endGame), for: UIControl.Event.touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: btnRight)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - helper functions
    
    @objc func loadPlayerHistory() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let gameDetailsVC = storyBoard.instantiateViewController(withIdentifier: "PlayerGameDetailsVC") as! PlayerGameDetailsVC
        self.navigationController?.pushViewController(gameDetailsVC, animated: true)
    }
    
    @objc func resetGame() {
        playGameViewModel.updatePlayCount()
        if playGameViewModel.playCount == 10 {
            let score1 = playGameViewModel.currentPlayerScore[0]
            let score2 = playGameViewModel.currentPlayerScore[1]
            if  score2 > score1 {
                displayAlertWith(title: "Result", message: "\(playGameViewModel.currentPlayerList[0].playerName ?? "") lost against \(playGameViewModel.currentPlayerList[1].playerName ?? "") by \(score2 - score1)")
            } else {
                displayAlertWith(title: "Result", message: "\(playGameViewModel.currentPlayerList[1].playerName ?? "") lost against \(playGameViewModel.currentPlayerList[0].playerName ?? "") by \(score1 - score2)")
            }
            saveScoreToDB()
            playGameViewModel.updatePlayCount()
        }
        self.dismiss(animated: true)
        UIView.animate(withDuration: 1.0, animations: { [unowned self] in
            if let frame = self.strikerPreviousPosition {
                self.striker.frame = frame
                self.playGameViewModel.resetPinTransforms()
            }
        }, completion: { _ in
            self.done = false
            self.panGesture.isEnabled = true
            self.striker.isUserInteractionEnabled = true
            self.xCoord = []
            self.yCoord = []
            if self.playGameViewModel.playCount%2 != 0 {
                self.perform(#selector(self.playBotGame), with: nil, afterDelay: 2.0)
            }
        })
    }
    
   @objc func playBotGame() {
       self.view.bringSubviewToFront(striker)
       let translation = panGesture.translation(in: self.view)
       let velocity = CGPoint(x: playGameViewModel.botVelocity.0 + CGFloat(arc4random_uniform(25)), y: playGameViewModel.botVelocity.1 - CGFloat(arc4random_uniform(30)))
       panStrikerFor(translation: translation, velocity: velocity, sender: panGesture)
    }
    
    @objc func endGame() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - coordinate helpers
    
    func addCoordinates() {
        playGameViewModel.addImageCoordinates(with: [pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8, pin9, pin10])
    }
    
    // MARK: - striker actions
    
    func moveUp(img: UIImageView, velocity: CGPoint) {
        print("y : \(img.center.y)")
        img.isUserInteractionEnabled = false
        var vx = velocity.x // Velocity x px
        var vy = abs(velocity.y) // Velocity y px
        var x = img.center.x // Initial position x
        var y = img.center.y // Initial position y
       // var coord: [[CGFloat]] = [];
//        var yCoord: [CGFloat] = []
//        var xCoord: [CGFloat] = []
        //var vx = velocity.x
        while(vy > 0.5) {
            x = x - vx
            y = y - vy
            
           // coord.append([x, y])
            print("x = \(x) and y = \(y)")
//            if x <= 0 {
//                x = 20
//            }
            if y <= 0 {
                y = 40
            }
            yCoord.append(y)
            xCoord.append(x)
            UIImageView.animate(withDuration: 1) { [unowned self] in
                //img.center.y += velocity.y
                //print("\(vy)")
                img.center.x += vx
                img.center.y -= vy
                vx = vx * self.friction;
                vy = vy * self.friction;
                //print("\(vy)")
            }
        }
        self.perform(#selector(performCoordinatesForStrikerHitAction), with: nil, afterDelay: 2.0)
    }
    
    @objc func performCoordinatesForStrikerHitAction() {
        let pinArray = self.playGameViewModel.filterPinAndCoordinatesForStrikerHit(strikerYCord: yCoord, strikerXCord: xCoord)
        animateImages(with: pinArray)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        self.view.bringSubviewToFront(striker)
        let translation = sender.translation(in: self.view);
        let velocity = sender.velocity(in: self.view);
        
        panStrikerFor(translation: translation, velocity: velocity, sender: sender)
    }
    
    func panStrikerFor(translation: CGPoint, velocity: CGPoint, sender: UIPanGestureRecognizer) {
        striker.center = CGPoint(x: striker.center.x + translation.x, y: striker.center.y + translation.y)
        if(striker.center.y <= 1000 && !self.done) {
            print(done)
            self.done = true;
            self.moveUp(img: self.striker, velocity: velocity)
            sender.isEnabled = false
        } else {
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    func animateImages(with pinArray: [PinCoordinateModel]) {
        UIView.animate(withDuration: 1.0) { [unowned self] in
            for pin in pinArray {
                let transform = CATransform3DIdentity
                pin.imageView.layer.transform =  CATransform3DRotate(transform, -120, 1.0, 1.0, 1.0)
            }
            displayScore(score: pinArray.count)
        } completion: { _ in
            self.perform(#selector(self.resetGame), with: nil, afterDelay: 2.0)
        }
    }
    
    func displayScore(score: Int) {
        let localscore = score > 10 ? 10 : score
        if playGameViewModel.playCount != 10 {
            if score == 0 {
                displayAlertWith(title: "Foul", message: "Sorry, give a next try")
            } else {
               displayAlertWith(title: "Score : \(localscore)", message: "Your score will be added to total play score")
            }
            if playGameViewModel.playCount%2 == 0 {
                playGameViewModel.currentPlayerScore[0] += localscore
            } else {
                playGameViewModel.currentPlayerScore[1] += localscore
            }
        }
    }
    
    func saveScoreToDB() {
        let score1 = playGameViewModel.currentPlayerScore[0]
        let score2 = playGameViewModel.currentPlayerScore[1]
        let result = score1 > score2 ? true : false
        let todaysDateString = dateFormatter.string(from: Date())
        let todaysDate = dateFormatter.date(from: todaysDateString)
        let gameData1 = NSEntityDescription.insertNewObject(forEntityName: "GameData", into: managedContext) as! GameData
        gameData1.gameType = "multiple"
        gameData1.score = Int64(score1)
        gameData1.status = result
        gameData1.time =  todaysDate
        let player1 = self.playGameViewModel.currentPlayerList[0]
        gameData1.player = player1
        player1.addToGamedata(gameData1)
        let gameData2 = NSEntityDescription.insertNewObject(forEntityName: "GameData", into: managedContext) as! GameData
        gameData2.gameType = "multiple"
        gameData2.score = Int64(score2)
        gameData2.status = !result
        gameData2.time = todaysDate
        let player2 = self.playGameViewModel.currentPlayerList[1]
        gameData2.player = player2
        player2.addToGamedata(gameData2)
        do {
            try managedContext.save()
        } catch {
            print("exception saving game data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - alert actions
    
    func displayAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
}

