//
//  Page.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import Firebase

enum PageType: String, Codable {
    case draw
    case drawType
    case type
    case read
    case none
    case book
}

private enum Width {
    case small, medium, large
    
    var value: CGFloat {
        switch self {
        case .small:
            return 4.0
        case .medium:
            return 12.0
        case .large:
            return 24.0
        }
    }
}

class Page {
    var pageType: PageType = .none
    var title: String
    var id: String
    var date: Date
    var editedAt: Date?
    var notes: String
    var drawing = ""
    var bookId: String = ""
    var imageRef = ""
    var authorId = ""
    
    init(pageType: PageType, title: String, id: String, date: Date, notes: String, drawing: String) {
        self.pageType = pageType
        self.title = title
        self.id = id
        self.date = date
        self.notes = notes
        self.drawing = drawing
        self.editedAt = nil
    }
    
    init() {
        title  = ""; id  = ""; notes = ""
        date = Date(); editedAt = Date()
    }
    
    init(data: QueryDocumentSnapshot){
        
        if let title = data["title"] as? String {
            self.title = title
        } else {
            self.title = ""
        }
        
        if let noteType = data["noteType"] as? String {
            self.pageType = PageType(rawValue: noteType) ?? .none
        }
        
        if let id = data["id"] as? String {
            self.id = id
        } else {
            self.id = ""
        }
        
        if let date = data["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            let dates = dateFormatter.date(from: date)
            
            self.date = dates ?? Date.now
        } else {
            self.date = Date.now
        }
        
        if let date = data["editedAt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            let dates = dateFormatter.date(from: date)
            
            self.editedAt = dates ?? nil
        } else {
            self.editedAt = nil
        }
        
        if let notes = data["note"] as? String {
            self.notes = notes
            if self.pageType == .type {
                self.title = notes 
            }
        } else {
            self.notes = ""
        }
        
        if let authorId = data["authorId"] as? String {
            self.authorId = authorId
        }
        
        if let bookId = data["bookId"] as? String {
            self.bookId = bookId
        } else {
            self.bookId = ""
        }
        
        if let imageRef = data["imageRef"] as? String {
           
            self.imageRef = imageRef
        }
        
        if let url = data["drawUrl"] as? String {
           
            self.drawing = url
        }
    }
}
