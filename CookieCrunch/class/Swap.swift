//
//  Swap.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 02.12.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import Foundation


struct Swap:CustomStringConvertible,Hashable {
    
    let swipeFromCookies:Cookie
    let swipeToCookies:Cookie
    
    
    init(swipeFrom:Cookie,swipeTo:Cookie) {
        self.swipeFromCookies=swipeFrom
        self.swipeToCookies=swipeTo
    }
    
    
    var description: String{
        return "swipeFromCookies: \(swipeFromCookies) swipeToCookies: \(swipeToCookies)"
    }
    
    static func ==(lhs: Swap, rhs: Swap) -> Bool {
        return
            (lhs.swipeFromCookies == rhs.swipeFromCookies && lhs.swipeToCookies == rhs.swipeToCookies)
                ||  (lhs.swipeToCookies == rhs.swipeFromCookies && lhs.swipeToCookies == rhs.swipeFromCookies)
    }
    
    var hashValue: Int{
        return swipeFromCookies.hashValue ^ swipeToCookies.hashValue
    }
    
    
}

