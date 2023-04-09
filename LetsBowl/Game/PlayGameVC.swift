//
//  PlayGameVC.swift
//  LetsBowl
//
//  Created by pitta, Banu on 24/02/23.
//

import Foundation
import UIKit
import CoreData
import SpriteKit
import CoreMotion

class PlayGameVC: UIViewController {
    
    @IBOutlet weak var strikerBorderview: UIView!
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
    var gameSound: PlayGameSounds = PlayGameSounds()
    var yCoord: [CGFloat] = []
    var xCoord: [CGFloat] = []
    
    var motionManager: CMMotionManager!
    
    var leftBezierPath: UIBezierPath!
    var leftShapeLayer: CAShapeLayer!
    var leftMoveLabel: UILabel!
    var rightBezierPath: UIBezierPath!
    var rightShapeLayer: CAShapeLayer!
    var rightMoveLabel: UILabel!
    var timer: Timer!
    var isGyroStarted: Bool = false
    var previousOriginX: Double = 0
    
    var acceleroBezierPath: UIBezierPath!
    var acceleroShapeLayer: CAShapeLayer!
    var acceleroStatusLabel: UILabel!
    var isAccelerateStarted = false
    
    
    // MARK: - view life cycles
    
    override func viewDidLoad() {
        self.title = "Play Game"
        dateFormatter.dateFormat = "dd-MM-yyyy"
        addBarButtonItems()
        self.playGameViewModel.updateCurrentPlayerList(with: player)
        gameSound.playerDelegate = self
        self.playSound(sound: .startGame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addCoordinates()
        if self.strikerPreviousPosition == nil {
            self.strikerPreviousPosition = self.striker.frame
        }
        if UserDefaults.standard.useGyroToPosition {
            drawAndAnimateGyroPath()
        } else {
            addPanGesture()
        }
    }
    
    deinit {
        motionManager = nil
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
    
    // MARK: - coordinate helpers
    
    func addCoordinates() {
        playGameViewModel.addImageCoordinates(with: [pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8, pin9, pin10])
    }
    
    // MARK: - grycoscope actions
    
    func drawAndAnimateGyroPath() {
        let leftStartpoint = CGPoint(x: striker.frame.midX - 10, y: striker.frame.minY + 10)
        let leftEndpoint = CGPoint(x: self.view.frame.minX, y: striker.frame.minY + 10)
        leftBezierPath = UIBezierPath()
        leftBezierPath.move(to: leftStartpoint)
        leftBezierPath.addLine(to: leftEndpoint)
        leftShapeLayer = CAShapeLayer()
        leftShapeLayer.path = leftBezierPath.cgPath
        leftShapeLayer.strokeColor = AppConstants.strikeColor.cgColor
        leftShapeLayer.lineWidth = striker.frame.width
        leftShapeLayer.cornerRadius = AppConstants.bgViewCornerRadius
        self.view.layer.addSublayer(leftShapeLayer)
        let leftFrame = CGRect(x: 0, y: striker.frame.minY - 10, width: 0.0, height: striker.frame.height + 2)
        leftMoveLabel = UILabel(frame: leftFrame)
        self.view.addSubview(leftMoveLabel)
        leftMoveLabel.text = "Tilt device to position striker to left"
        leftMoveLabel.numberOfLines = 2
        leftMoveLabel.textAlignment = .left
        
        let rightStartpoint = CGPoint(x: striker.frame.midX + 45, y: striker.frame.minY + 10)
        let rightEndpoint = CGPoint(x: self.view.frame.maxX, y: striker.frame.minY + 10)
        rightBezierPath = UIBezierPath()
        rightBezierPath.move(to: rightStartpoint)
        rightBezierPath.addLine(to: rightEndpoint)
        rightShapeLayer = CAShapeLayer()
        rightShapeLayer.path = rightBezierPath.cgPath
        rightShapeLayer.strokeColor = AppConstants.strikeColor.cgColor
        rightShapeLayer.lineWidth = striker.frame.width
        rightShapeLayer.cornerRadius = AppConstants.bgViewCornerRadius
        self.view.layer.addSublayer(rightShapeLayer)
        let rightFrame = CGRect(x: striker.frame.midX + 45, y: striker.frame.minY - 10, width: 0.0 , height: striker.frame.height + 2)
        rightMoveLabel = UILabel(frame: rightFrame)
        self.view.addSubview(rightMoveLabel)
        rightMoveLabel.text = "Tilt device to position striker to Right"
        rightMoveLabel.numberOfLines = 2
        rightMoveLabel.textAlignment = .left
        UIView.animate(withDuration: 3.0) { [weak self] in
            self?.leftMoveLabel.frame.size.width =  ((self?.view.frame.width ?? 0.0)/2) - (self?.striker.frame.width ?? 0.0)
            self?.rightMoveLabel.frame.size.width = (self?.view.frame.width ?? 0.0/2) - (self?.striker.frame.width ?? 0.0)
        } completion: { [weak self] _ in
            self?.leftMoveLabel.removeFromSuperview()
            self?.leftMoveLabel = nil
            self?.leftBezierPath = nil
            self?.leftShapeLayer.removeFromSuperlayer()
            self?.leftShapeLayer = nil
            self?.rightMoveLabel.removeFromSuperview()
            self?.rightMoveLabel = nil
            self?.rightBezierPath = nil
            self?.rightShapeLayer.removeFromSuperlayer()
            self?.rightShapeLayer = nil
            self?.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self!, selector: #selector(self?.timeDifferenceBetweenTilt), userInfo: nil, repeats: true)
            self?.addMotionManager()
            self?.isGyroStarted = true
        }
    }
    
    @objc func timeDifferenceBetweenTilt() {
        let difference = previousOriginX - striker.frame.origin.x
        if (difference > 0 && difference < 10) || (difference < 0 && difference < -5) || (Int(previousOriginX) == Int(striker.frame.origin.x)) {
            timer.invalidate()
            timer = nil
            isGyroStarted = false
            if UserDefaults.standard.useAcceleroToStrike {
                drawPathBtwStrikerAndPins()
                striker.isUserInteractionEnabled = false
            } else {
                displayAlertWith(title: "Striker position is set", message: "Striker position has been set. Please play the game")
                addPanGesture()
            }
        }
    }
    
    
    // MARK: - Tilt actions
    
    func setStrikerRandomXPosition() {
        let randomxpos = Int(arc4random_uniform(UInt32(self.view.frame.width - striker.frame.width)) + 1)
        striker.translatesAutoresizingMaskIntoConstraints = true
        striker.frame.origin.x = CGFloat(randomxpos)
        striker.layoutIfNeeded()
    }
    
    func drawPathBtwStrikerAndPins() {
        let startpoint = CGPoint(x: striker.frame.origin.x + striker.frame.width/2, y: striker.frame.minY)
        let endpoint = CGPoint(x: pin1.frame.origin.x + pin1.frame.width/2, y: pin1.frame.maxY)
        acceleroBezierPath = UIBezierPath()
        acceleroBezierPath.move(to: startpoint)
        acceleroBezierPath.addLine(to: endpoint)
        acceleroShapeLayer = CAShapeLayer()
        acceleroShapeLayer.path = acceleroBezierPath.cgPath
        acceleroShapeLayer.strokeColor = AppConstants.strikeColor.cgColor
        acceleroShapeLayer.lineWidth = striker.frame.width
        acceleroShapeLayer.cornerRadius = AppConstants.bgViewCornerRadius
        view.layer.addSublayer(acceleroShapeLayer)
        let frame = CGRect(x: 20.0, y: striker.frame.minY - 10, width: 0.0, height: striker.frame.height + 2)
        acceleroStatusLabel = UILabel(frame: frame)
        self.view.addSubview(acceleroStatusLabel)
        acceleroStatusLabel.text = "Rotate device up and sides to move striker"
        acceleroStatusLabel.numberOfLines = 2
        acceleroStatusLabel.textAlignment = .left
        UIView.animate(withDuration: 3.0) { [unowned self] in
            self.acceleroStatusLabel.frame.size.width = self.view.frame.width/2 - striker.frame.width
        } completion: { [unowned self] _ in
            self.acceleroStatusLabel.removeFromSuperview()
            self.acceleroStatusLabel = nil
            self.isAccelerateStarted = true
        }
    }
    
    func addMotionManager() {
        motionManager = nil
        motionManager = CMMotionManager()
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            if let isGyroStarted = self?.isGyroStarted, isGyroStarted {
                self?.striker.translatesAutoresizingMaskIntoConstraints = true
                let roll = data?.attitude.roll ?? 0
                let originX = (self?.striker.frame.origin.x ?? 0.0) + (roll * 10)
                if (originX < self?.striker.frame.width ?? 0.0) || (originX > (self?.view.frame.maxX ?? 0.0) - (self?.striker.frame.width ?? 0.0)) {
                    return
                }
                self?.previousOriginX = Double(self?.striker.frame.origin.x ?? 0.0)
                self?.striker.frame.origin.x = originX
                self?.striker.layoutIfNeeded()
            } else if let isAccelerateStarted = self?.isAccelerateStarted, isAccelerateStarted {
                self?.striker.translatesAutoresizingMaskIntoConstraints = true
                let roll = data?.attitude.roll ?? 0
                let originX = (self?.striker.frame.origin.x ?? 0.0) + roll
                let pitch = data?.attitude.pitch ?? 0
                let originY = (self?.striker.frame.origin.y ?? 0.0) + (pitch * 50)
                if originY > (self?.strikerBorderview.frame.maxY ?? 0.0) {
                    return
                }
                self?.yCoord.append(originY)
                self?.xCoord.append(originX)
                if originY < self?.pinBgView.frame.minY ?? 0.0 {
                    self?.isAccelerateStarted = false
                    self?.acceleroBezierPath = nil
                    self?.acceleroShapeLayer.removeFromSuperlayer()
                    self?.acceleroShapeLayer = nil
                    self?.performCoordinatesForStrikerHitAction()
                    return
                }
                self?.striker.frame.origin = CGPoint(x: originX, y: originY)
                self?.striker.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Pan actions
    
    func addPanGesture() {
        striker.removeGestureRecognizer(panGesture)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        striker.isUserInteractionEnabled = true
        striker.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        self.view.bringSubviewToFront(striker)
        let translation = sender.translation(in: self.view);
        let velocity = sender.velocity(in: self.view);
        
        panStrikerFor(translation: translation, velocity: velocity, sender: sender)
    }
    
    func panStrikerFor(translation: CGPoint, velocity: CGPoint, sender: UIPanGestureRecognizer) {
        striker.center = CGPoint(x: striker.center.x + translation.x, y: striker.center.y + translation.y)
        if(striker.center.y <= 3000 && !self.done) {
            print(done)
            self.done = true;
            self.moveUp(img: self.striker, velocity: velocity)
            sender.isEnabled = false
        } else {
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    // MARK: - striker actions
    
    func moveUp(img: UIImageView, velocity: CGPoint) {
        img.isUserInteractionEnabled = false
        var vx = velocity.x
        var vy = abs(velocity.y)
        var x = img.center.x
        var y = img.center.y
        while(vy > 0.5) {
            x = x - vx
            y = y - vy
            if y <= 0 {
                y = 40
            }
            yCoord.append(y)
            xCoord.append(x)
            UIImageView.animate(withDuration: 1) { [unowned self] in
                img.center.x += vx
                img.center.y -= vy
                vx = vx * self.friction;
                vy = vy * self.friction;
            }
        }
        self.perform(#selector(performCoordinatesForStrikerHitAction), with: nil, afterDelay: 2.0)
    }
    
    @objc func performCoordinatesForStrikerHitAction() {
        let pinArray = self.playGameViewModel.filterPinAndCoordinatesForStrikerHit(strikerYCord: yCoord, strikerXCord: xCoord)
        animateImages(with: pinArray)
        playSound(sound: pinArray.count > 0 ? .shotSuccess : .foul)
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
    
    func displayAlertWith(title: String, message: String, useAction: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var dismiss: UIAlertAction!
        if useAction {
            dismiss = UIAlertAction(title: "OK", style: .cancel, handler: { [unowned self] _ in
                self.resetCoordinates()
            })
        } else {
            dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        }
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - sounds
    
    func playSound(sound: Sound) {
        gameSound.startPlayback(with: sound)
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
                displayAlertWith(title: "Result", message: "\(playGameViewModel.currentPlayerList[0].playerName ?? "") lost against \(playGameViewModel.currentPlayerList[1].playerName ?? "") by \(score2 - score1)", useAction: true)
            } else {
                displayAlertWith(title: "Result", message: "\(playGameViewModel.currentPlayerList[1].playerName ?? "") lost against \(playGameViewModel.currentPlayerList[0].playerName ?? "") by \(score1 - score2)", useAction: true)
            }
            saveScoreToDB()
            playGameViewModel.updatePlayCount()
            return
        }
        resetCoordinates()
    }
    
    func resetCoordinates() {
        self.dismiss(animated: true)
        UIView.animate(withDuration: 1.0, animations: { [unowned self] in
            if let frame = self.strikerPreviousPosition {
                self.striker.frame = frame
                self.playGameViewModel.resetPinTransforms()
            }
        }, completion: { [unowned self] _ in
            self.done = false
            if !UserDefaults.standard.useAcceleroToStrike {
                self.panGesture.isEnabled = true
                self.striker.isUserInteractionEnabled = true
            }
            self.xCoord = []
            self.yCoord = []
            if self.playGameViewModel.playCount%2 != 0 {
                self.perform(#selector(self.playBotGame), with: nil, afterDelay: 2.0)
            }
        })
        self.perform(#selector(resetGyroPath), with: nil, afterDelay: 2.0)
    }
    
    @objc func resetGyroPath() {
        if UserDefaults.standard.useGyroToPosition && self.playGameViewModel.playCount%2 == 0{
            self.previousOriginX = 0
            self.drawAndAnimateGyroPath()
        }
    }
    
   @objc func playBotGame() {
       if UserDefaults.standard.useAcceleroToStrike {
          addPanGesture()
       }
       self.view.bringSubviewToFront(striker)
       let translation = panGesture.translation(in: self.view)
       let velocity = CGPoint(x: playGameViewModel.botVelocity.0 + CGFloat(arc4random_uniform(25)), y: playGameViewModel.botVelocity.1 - CGFloat(arc4random_uniform(30)))
       panStrikerFor(translation: translation, velocity: velocity, sender: panGesture)
    }
    
    @objc func endGame() {
        gameSound.startPlayback(with: .endGame)
        gameSound.playerDelegate = nil
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension PlayGameVC: PlayerDelegate {
    func playbackStarted() {
        self.view.isUserInteractionEnabled = false
    }
    
    func playbackEnded() {
        self.view.isUserInteractionEnabled = true
    }
}
