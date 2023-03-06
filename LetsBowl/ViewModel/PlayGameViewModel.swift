//
//  PlayGameViewModel.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 28/02/23.
//

import Foundation
import UIKit
import CoreData

enum HitPosition {
    case none
    case left
    case right
    case center
}

class PlayGameViewModel {
    
    var pinCoordinates: [PinCoordinateModel] = []
    var defaultTransform: [CATransform3D] = []
    let leftBarBtnTitle = "Play History"
    let rightBarBtnTitle = "Exit game"
    var playCount = 0
    var currentPlayerList: [Player]!
    var currentPlayerScore: [Int] = [0,0]
    let botVelocity: (CGFloat, CGFloat) = (0.0, -400.0)
    
    // MARK: - helper functions
    
    func updatePlayCount() {
        if playCount != 10 {
            playCount += 1
        } else {
            playCount = 0
            currentPlayerScore = [0,0]
        }
    }
    
    func updateCurrentPlayerList(with list: [Player]) {
        self.currentPlayerList = list
    }
    
    // MARK: - add coordinates
    
    func addImageCoordinates(with imageArray: [UIImageView]) {
        for(index, pin) in imageArray.enumerated() {
            addPin(imageView: pin, with: index)
        }
    }
    
    func addPin(imageView: UIImageView, with tag: Int) {
        let leftBottom = imageView.frame.minY + imageView.frame.size.height
        let pinCoordinate = PinCoordinateModel(leftTop: imageView.frame.minX, leftBottm: leftBottom, rightTop: imageView.frame.maxX, rightBottom: imageView.frame.maxY, imageView: imageView, tag: tag)
        self.pinCoordinates.append(pinCoordinate)
        self.defaultTransform.append(imageView.layer.transform)
    }
    
    func resetPinTransforms() {
        for (index, pin) in pinCoordinates.enumerated() {
            pin.imageView.layer.transform = defaultTransform[index]
        }
    }
    
    // MARK: - caliculations
    
    func filterPinAndCoordinatesForStrikerHit(strikerYCord: [CGFloat], strikerXCord: [CGFloat]) -> [PinCoordinateModel] {
        print(strikerYCord)
        print(strikerXCord)
        var pinsToFall: [PinCoordinateModel] = []
        for (index, pin) in pinCoordinates.enumerated() {
            pinsToFall.removeAll()
            if index == 0 {
                let hitStatus = getIndexOfPinHit(strikerYCord: strikerYCord, strikerXCord: strikerXCord, pinArr: [pin]).0
                if hitStatus == .left {
                    pinsToFall.append(pinCoordinates[0])
                    pinsToFall.append(pinCoordinates[2])
                    pinsToFall.append(pinCoordinates[5])
                    pinsToFall.append(pinCoordinates[9])
                    return pinsToFall
                } else if hitStatus == .right {
                    pinsToFall.append(pinCoordinates[0])
                    pinsToFall.append(pinCoordinates[1])
                    pinsToFall.append(pinCoordinates[3])
                    pinsToFall.append(pinCoordinates[6])
                    return pinsToFall
                } else if hitStatus == .center {
                    return pinCoordinates
                }
            } else if index >= 1 && index <= 2 {
                let coordTuple = getIndexOfPinHit(strikerYCord: strikerYCord, strikerXCord: strikerXCord, pinArr: Array(pinCoordinates[1...2]))
                let hitStatus = coordTuple.0
                let pinIndex = coordTuple.1
                if hitStatus == .left {
                    if pinIndex == 0 {
                        pinsToFall.append(pinCoordinates[1])
                        pinsToFall.append(pinCoordinates[4])
                        pinsToFall.append(pinCoordinates[8])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .right {
                    if pinIndex == 1 {
                        pinsToFall.append(pinCoordinates[2])
                        pinsToFall.append(pinCoordinates[4])
                        pinsToFall.append(pinCoordinates[7])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .center {
                    return Array(pinCoordinates[1...9])
                }
            } else if index >= 3 && index <= 5 {
                let coordTuple = getIndexOfPinHit(strikerYCord: strikerYCord, strikerXCord: strikerXCord, pinArr: Array(pinCoordinates[3...5]))
                let hitStatus = coordTuple.0
                let pinIndex = coordTuple.1
                if hitStatus == .left {
                    if pinIndex == 3 {
                        pinsToFall.append(pinCoordinates[3])
                        pinsToFall.append(pinCoordinates[7])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .right {
                    if pinIndex == 5 {
                        pinsToFall.append(pinCoordinates[5])
                        pinsToFall.append(pinCoordinates[8])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .center {
                    return Array(pinCoordinates[3...9])
                }
            } else if index >= 6 && index <= 9 {
                let coordTuple = getIndexOfPinHit(strikerYCord: strikerYCord, strikerXCord: strikerXCord, pinArr: Array(pinCoordinates[6...9]))
                let hitStatus = coordTuple.0
                let pinIndex = coordTuple.1
                if hitStatus == .left {
                    if pinIndex == 3 {
                        pinsToFall.append(pinCoordinates[6])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .right {
                    if pinIndex == 5 {
                        pinsToFall.append(pinCoordinates[9])
                        return pinsToFall
                    } else {
                        return []
                    }
                } else if hitStatus == .center {
                    let subtractInd = 6-pinIndex
                    pinsToFall.append(pinCoordinates[subtractInd])
                    return pinsToFall
                }
            }
        }
        return []
    }
    
    func getIndexOfPinHit(strikerYCord: [CGFloat], strikerXCord: [CGFloat], pinArr: [PinCoordinateModel]) -> (HitPosition, Int) {
        for (index, pin) in pinArr.enumerated() {
            let frame = pin.imageView.superview?.superview?.convert(pin.imageView.frame, from:pin.imageView.superview)
            for (imageXIndex, _) in strikerXCord.enumerated() {
                for(imageYIndex, _) in strikerYCord.enumerated(){
                    if let frame = frame {
                        if (strikerXCord[imageXIndex] >= frame.origin.x && strikerXCord[imageXIndex] <= (frame.origin.x + frame.size.width)) && (strikerYCord[imageYIndex] <= frame.origin.y + frame.size.height && strikerYCord[imageYIndex] >= frame.origin.y) {
                            return (.center, index)
                        }
                    }
                }
                
            }
            
        }
        return (.none, -1)
    }
}
