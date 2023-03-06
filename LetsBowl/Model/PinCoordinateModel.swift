//
//  PinCoordinateModel.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 26/02/23.
//

import Foundation
import UIKit

//struct PinCoordinateModel {
//    var originX: CGFloat = 0
//    var originY: CGFloat = 0
//    var velocityX: CGFloat = 0
//    var velocityY: CGFloat = 0
//
//    init(originX: CGFloat = 0, originY: CGFloat = 0, velocityX: CGFloat = 0, velocityY: CGFloat = 0) {
//        self.originX = originX
//        self.originY = originY
//        self.velocityX = velocityX
//        self.velocityY = velocityY
//    }
//}

struct PinCoordinateModel {
    var imageView: UIImageView = UIImageView()
    var tag: Int = 0
    var leftTop: CGFloat = 0
    var leftBottom: CGFloat = 0
    var rightTop: CGFloat = 0
    var rightBottom: CGFloat = 0
    
    init(leftTop: CGFloat, leftBottm: CGFloat, rightTop: CGFloat, rightBottom: CGFloat, imageView: UIImageView, tag: Int) {
        self.leftTop = leftTop
        self.leftBottom = leftBottm
        self.rightTop = rightTop
        self.rightBottom = rightBottom
        self.imageView = imageView
        self.tag = tag
    }
}
