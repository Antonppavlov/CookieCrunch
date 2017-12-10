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
let NumLevel = 4

class Level {
    
    fileprivate var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var posibleSwap = Set<Swap>()
    
    var comboMultiplier = 0
    
    var targetScore = 0
    var maximumMoves = 0
    
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
        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int
    }
    
    func tileAt(column:Int, row:Int)->Tile? {
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
        var setCookie: Set<Cookie>
        repeat{
            setCookie = createInitialCookie()
            detectedPossibleSwaps()
            print(posibleSwap)
        }while (posibleSwap.count == 0)
        
        
        return setCookie;
    }
    
    func detectedPossibleSwaps() {
        posibleSwap = Set<Swap>()
        
        for row in 0 ..< NumRows {
            for column in 0 ..< NumColumns {
                
                if let cookie = cookies[column,row] {
                    if column < NumColumns - 1 {
                        checkPossibleSwipeCookie(cookie, column + 1, row)
                    }
                    if  column <= NumColumns && column > 0 {
                        checkPossibleSwipeCookie(cookie, column - 1, row)
                    }
                    if  row < NumRows - 1 {
                        checkPossibleSwipeCookie(cookie, column, row + 1)
                    }
                    if  row <= NumRows && row > 0 {
                        checkPossibleSwipeCookie(cookie, column, row - 1)
                    }
                }
            }
        }
    }
    
    func isPosibleSwap(swap:Swap)->Bool  {
        return posibleSwap.contains(swap)
    }
    
    func checkPossibleSwipeCookie(_ cookie:Cookie ,_ column:Int,_ row:Int){
        
        if let cookieSwipe = cookies[column, row]{
            let swap = Swap(swipeFrom: cookie, swipeTo: cookieSwipe)
            performSwap(swap)
            
            if hasChainAt(column: cookie.column, row: cookie.row){
                posibleSwap.insert(swap)
            }
            
            let swapBack = Swap(swipeFrom: cookieSwipe,swipeTo: cookie)
            performSwap(swapBack)
        }
        
    }
    
    private func hasChainAt(column: Int, row: Int) ->Bool{
        let swipeCookieType = cookies[column,row]?.cookieType
        
        // Horizontal chain check
        var sumEqualCookiesToHorizon = 1
        // Left
        var columnLeftCookieHorizon = column - 1
        while columnLeftCookieHorizon >= 0 && cookies[columnLeftCookieHorizon,row]?.cookieType == swipeCookieType {
            columnLeftCookieHorizon -= 1
            sumEqualCookiesToHorizon += 1
        }
        // Right
        var columnRightCookieHorizon = column + 1
        while columnRightCookieHorizon < NumColumns && cookies[columnRightCookieHorizon,row]?.cookieType == swipeCookieType {
            columnRightCookieHorizon += 1
            sumEqualCookiesToHorizon += 1
        }
        
        if(sumEqualCookiesToHorizon >= 3){return true}
        
        //Vertical chain check
        var sumEqualCookiesToVertical = 1
        // Down
        var rowDownCookieHorizon = row - 1
        while rowDownCookieHorizon >= 0 && cookies[column,rowDownCookieHorizon]?.cookieType == swipeCookieType {
            rowDownCookieHorizon -= 1
            sumEqualCookiesToVertical += 1
        }
        // Up
        var rowUpCookieHorizon = row + 1
        while rowUpCookieHorizon < NumRows && cookies[column,rowUpCookieHorizon]?.cookieType == swipeCookieType {
            rowUpCookieHorizon += 1
            sumEqualCookiesToVertical += 1
        }
        
        return sumEqualCookiesToVertical >= 3
    }
    
    
    
    fileprivate func createInitialCookie () -> Set<Cookie> {
        var setCookie = Set<Cookie>()
        
        for row in 0 ..< NumRows{
            for column in 0 ..< NumColumns{
                if(tiles[column,row] != nil){
                    var cookieType:CookieType
                    
                    repeat {
                        cookieType = CookieType.random()
                    }while((column >= 2 && cookies[column - 1 ,row]?.cookieType==cookieType && cookies[column - 2 ,row]?.cookieType==cookieType) || (row >= 2 && cookies[column ,row - 1]?.cookieType==cookieType && cookies[column ,row - 2]?.cookieType==cookieType))
                    
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    self.cookies[column,row] = cookie
                    setCookie.insert(cookie)
                }
            }
        }
        
        return setCookie
    }
    
    func performSwap(_ swap: Swap){
        let columnFrom = swap.swipeFromCookies.column
        let rowFrom = swap.swipeFromCookies.row
        let columnTo = swap.swipeToCookies.column
        let rowTo = swap.swipeToCookies.row
        
        cookies[columnFrom,rowFrom] = swap.swipeToCookies
        swap.swipeToCookies.column = columnFrom
        swap.swipeToCookies.row = rowFrom
        
        cookies[columnTo,rowTo] = swap.swipeFromCookies
        swap.swipeFromCookies.column = columnTo
        swap.swipeFromCookies.row = rowTo
    }
    
    
    private func detectHorizontalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for row in 0 ..< NumRows {
            var column = 0
            while column < NumColumns-2 {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column + 1, row]?.cookieType == matchType && cookies[column + 2, row]?.cookieType == matchType {
                        let chain = Chain(chainType: .horizontal)
                        repeat {
                            chain.add(cookie: cookies[column, row]!)
                            column += 1
                        } while column < NumColumns && cookies[column, row]?.cookieType == matchType
                        
                        setScoreChain(chain)
                        set.insert(chain)
                        continue
                    }
                }
                
                column += 1
            }
        }
        
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0 ..< NumColumns {
            var row = 0
            while row < NumRows-2 {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType && cookies[column, row + 2]?.cookieType == matchType {
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.add(cookie: cookies[column, row]!)
                            row += 1
                        } while row < NumRows && cookies[column, row]?.cookieType == matchType
                        
                        setScoreChain(chain)
                        set.insert(chain)
                        continue
                    }
                }
                
                row += 1
            }
        }
        
        return set
    }
    
    
    func removeMatches() -> Set<Chain>{
        let detectedVertical =  detectVerticalMatches()
        let detectedHorizontal = detectHorizontalMatches()
        
        removeCookies(detectedVertical)
        removeCookies(detectedHorizontal)
        
        return detectedVertical.union(detectedHorizontal)
    }
    
    private func removeCookies(_ chains:Set<Chain>){
        for chain in chains {
            for cookie in chain.cookies{
                cookies[cookie.column,cookie.row] = nil
            }
        }
    }
    
    //метод заменят удаленные печеньки после свайпа или замены на печеньку выше
    //возвращает все замененные печеньки в виде массива(колонки) массивов(строки)
    func fillHoles() -> [[Cookie]]{
        var arrayColums = [[Cookie]]()
        
        for column in 0 ..< NumColumns{
            var arrayRow = [Cookie]()
            
            for row in 0 ..< NumRows{
                if tiles[column,row] != nil && cookies[column,row] == nil{
                    for lookup in (row + 1) ..< NumRows{
                        if let cookie = cookies[column, lookup] {
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            
                            arrayRow.append(cookie)
                            
                            break;
                        }
                        
                    }
                }
            }
            if !arrayRow.isEmpty{
                arrayColums.append(arrayRow)
            }
            
        }
        
        
        return arrayColums
    }
    
    
    //метод заполняет удаленные печеньки с значением nil на объекты печенек
    //возвращает все замененные печеньки в виде массива(колонки) массивов(строки)
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .unknown
        
        for column in 0 ..< NumColumns {
            var array = [Cookie]()
            
            var row = NumRows - 1
            while row >= 0 && cookies[column, row] == nil {
                if tiles[column, row] != nil {
                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
                
                row -= 1
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        
        return columns
    }
    
    func resetComboMultiplier(){
        comboMultiplier = 1
    }
    
    func setScoreChain(_ chain:Chain) {
        chain.score = ((chain.cookies.count - 2) * 60) * comboMultiplier
        
        comboMultiplier += 1
    }
    
    
  
}


