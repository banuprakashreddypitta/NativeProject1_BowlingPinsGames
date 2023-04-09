//
//  UserDefaultsExtension.swift
//  LetsBowl
//
//  Created by Pitta, Banu on 05/04/23.
//

import Foundation

extension UserDefaults {
    
    var useGyroToPosition: Bool {
        get {
            bool(forKey: "useGyroToPosition")
        }
        set {
            set(newValue, forKey: "useGyroToPosition")
        }
    }
    
    var useAcceleroToStrike: Bool {
        get {
            bool(forKey: "useAcceleroToStrike")
        }
        set {
            set(newValue, forKey: "useAcceleroToStrike")
        }
    }
}
