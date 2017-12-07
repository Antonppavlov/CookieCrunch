//
//  Chain.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 05.12.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    
    
    var cookies = [Cookie]()
    var chainType:ChainType
    var lenght:Int{
        return cookies.count
    }
    
    init(chainType:ChainType){
        self.chainType = chainType
    }
    
    
    func add(cookie:Cookie){
        cookies.append(cookie)
    }
    
    func firstCookie() ->Cookie{
        return cookies[0]
    }
    
    func lastCookie() ->Cookie{
        return cookies[cookies.count - 1]
    }
    
    
    var hashValue: Int{
        return cookies.reduce(0) { $0.hashValue ^ $1.hashValue  }
    }
    
    var description: String {
        return "type: \(chainType) cookies \(cookies)"
    }
    
    static func ==(lhs: Chain, rhs: Chain) -> Bool {
        return  lhs.cookies == rhs.cookies
    }
    
    
    
    enum ChainType:CustomStringConvertible {
        case horizontal
        case vertical
        
        var description: String {
            switch self {
            case .horizontal:
                return "Horizontal"
            case .vertical:
                return "Vertical"
            }
        }
    }
}

