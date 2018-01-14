//
//  AppStorage.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 14.01.2018.
//  Copyright © 2018 Anton Pavlov. All rights reserved.
//

import Foundation

class AppStorage {
    static let currentLevel = "currentLevel"
    
    func fetchCurrentLevel() -> Int? {
        let currentLevel = UserDefaults.standard.integer(forKey: AppStorage.currentLevel)
        return currentLevel
    }
    
    func save(currentLevel: Int) {
        UserDefaults.standard.set(currentLevel, forKey: AppStorage.currentLevel)
    }
    
    func isCurrentLevel() -> Bool {
        let currentLevel = self.fetchCurrentLevel()
        return currentLevel != nil
    }
    
}

