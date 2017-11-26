//
//  Extensions.swift
//  CookieCrunch
//
//  Created by Anton Pavlov on 26.11.2017.
//  Copyright © 2017 Anton Pavlov. All rights reserved.
//

import Foundation

extension Dictionary{
    
    static func loadJsonFromBundle(fileName:String) -> Dictionary<String,AnyObject>? {
        var dataOk:Data
        var dictionaryOK: NSDictionary = NSDictionary()
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions()) as Data!
                dataOk = data!
            }catch{
                print("Could not lead level file: \(fileName), error:\(error)")
                return nil
            }
            do{
                let dictionary = try JSONSerialization.jsonObject(with: dataOk, options: JSONSerialization.ReadingOptions())
                dictionaryOK = (dictionary as! Dictionary as? Dictionary<String,AnyObject>)! as NSDictionary
            }catch{
                print("Level file: \(fileName), is not valide JSON:\(error)")
                return nil
            }
        }
        return dictionaryOK as? Dictionary<String,AnyObject>
    }
}

