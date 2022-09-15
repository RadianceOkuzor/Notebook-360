//
//  Singleton.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 9/15/22.
//

import Foundation

class Singleton {
    
    static let shared = Singleton()
    
    var bookId: String = "all"
    
    init() {
        
    }
}
