//
//  Level.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 26.11.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    
    init(fileName:String) {
        guard let dictionary =  Dictionary<String, AnyObject>.loadJsonFromBundle(fileName: fileName) else {return}
        guard let titlesArray = dictionary["tiles"] as? [[Int]] else {return}
        
        for(row , rowArray) in titlesArray.enumerated(){
            let titleRow = NumRows - row - 1
            
            for(column, value) in rowArray.enumerated(){
                if(value == 1){
                    tiles[column, titleRow] = Tile()
                }
            }
        }
    }
    
    
    fileprivate var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    func cookieAt(column:Int, row:Int)->Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && column < NumRows)
        
        return self.tiles[column,row]
    }
    
    func cookieAt(column:Int, row:Int)->Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && column < NumRows)
        
        return self.cookies[column,row]
    }
    
    func shuffle() -> Set<Cookie> {
        return createInitialCookie()
    }
    
    private func createInitialCookie () -> Set<Cookie> {
        var setCookie = Set<Cookie>()
        
        for row in 0 ..< NumRows{
            for column in 0 ..< NumColumns{
                if(tiles[column,row] != nil){
                    let cookieType = CookieType.random()
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    self.cookies[column,row] = cookie
                    setCookie.insert(cookie)
                    
                    
                
                }
               
            }
        }
        
        return setCookie
    }
}

