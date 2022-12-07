//
//  Page.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import Firebase
import CoreData

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

enum RowType {
    case page(CorePage)
    case book(CoreBook)
    
    var page: CorePage? {
        switch self {
        case .page(let page): return page
        case .book( _): return nil
        }
    }
    
    var book: CoreBook? {
        switch self {
        case .page( _): return nil
        case .book(let book): return book
        }
    }
}

struct Book {
    var color: String?
    var id: String
    var title: String
    var bookIds: [String]
}

class Page {
    var pageType: PageType = .none
    var title: String
    var id: String
    var date: Date
    var editedAt: Date?
    var notes: String
    var drawing: Data? = nil
    var bookId: String = ""
    var imageRef = ""
    var authorId = ""
    
    init(pageType: PageType, title: String, id: String, date: Date, notes: String, drawing: String) {
        self.pageType = pageType
        self.title = title
        self.id = id
        self.date = date
        self.notes = notes
        self.editedAt = nil
    }
    
    init(cPage: CorePage) {
        self.pageType = PageType(rawValue: cPage.pageType ?? "") ?? .none
        self.title = cPage.pageType ?? ""
        self.id = cPage.id ?? ""
        self.date = cPage.dateCreated ?? Date.now
        self.notes = cPage.notes ?? ""
        self.drawing = cPage.drawing
        self.bookId = cPage.book?.id ?? ""
        self.authorId = cPage.authorId ?? ""
        self.editedAt = cPage.dateEdited ?? Date.now
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
        
        if let _ = data["drawUrl"] as? String {
            
//            self.drawing = url
        }
    }
}

class DataManager {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentCoreModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    //Core Data Saving support
    func save () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func coreBook(book: Book) -> CoreBook {
        let cbook = CoreBook(context: persistentContainer.viewContext)
        cbook.id = book.id
        cbook.color = book.color
        cbook.title = book.title
        return cbook
    }
    
    func corePage(page: Page, cBook: CoreBook) -> CorePage {
        let cPage = CorePage(context: persistentContainer.viewContext)
        cPage.title = page.title
        cPage.id = page.id
        cPage.authorId = page.authorId
        cPage.dateCreated = page.date
        cPage.drawing = page.drawing
        cPage.notes = page.notes
        cPage.pageType = page.pageType.rawValue
        cPage.dateEdited = page.editedAt
        cBook.addToPages(cPage)
        return cPage
    }
    
    func coreBooks() -> [CoreBook] {
      let request: NSFetchRequest<CoreBook> = CoreBook.fetchRequest()
      var fetchedCoreBooks: [CoreBook] = []
      do {
          fetchedCoreBooks = try persistentContainer.viewContext.fetch(request)
      } catch let error {
         print("Error fetching core books \(error)")
      }
      return fetchedCoreBooks
    }
    
    func updateCoreBookBookList(book: CoreBook, idToAdd: String) {
        let string = StringHolder(context: persistentContainer.viewContext)
        string.string = idToAdd
        book.addToBookIds(string)
    }
    
    func updateCorePage(book: CoreBook, index: Int, notes: String?, drawing: Data?, isNotes: Bool) {
        let page = book.pages?.allObjects[index] as? CorePage
        if isNotes {
//            page?.notes = notes
            page?.setValuesForKeys(["notes":notes ?? [:]])
        } else {
//            page?.drawing = drawing
            page?.setValuesForKeys(["drawing":drawing ?? [:]])
        }
//        DataManager.shared.save()
    }
    
    func corePages(coreBook: CoreBook, filter: String = "dateEdited") -> [CorePage] {
      let request: NSFetchRequest<CorePage> = CorePage.fetchRequest()
      request.predicate = NSPredicate(format: "book = %@", coreBook)
      request.sortDescriptors = [NSSortDescriptor(key: filter, ascending: false)]
      var fetchedPages: [CorePage] = []
      do {
          fetchedPages = try persistentContainer.viewContext.fetch(request)
      } catch let error {
        print("Error fetching pages \(error)")
      }
      return fetchedPages
    }
    
    func bookIds(coreBook: CoreBook) -> [StringHolder] {
      let request: NSFetchRequest<StringHolder> = StringHolder.fetchRequest()
      request.predicate = NSPredicate(format: "book = %@", coreBook)
      
      var fetchedIds: [StringHolder] = []
      do {
          fetchedIds = try persistentContainer.viewContext.fetch(request)
      } catch let error {
        print("Error fetching pages \(error)")
      }
      return fetchedIds
    }
    
    func deletePage(corePage: CorePage) {
      let context = persistentContainer.viewContext
      context.delete(corePage)
      save()
    }
    func deleteBook(coreBook: CoreBook) {
      let context = persistentContainer.viewContext
      context.delete(coreBook)
      save()
    }
}
