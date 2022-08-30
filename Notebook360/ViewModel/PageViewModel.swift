//
//  PageViewModel.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import EventKit

class PageViewModel: NSObject {
    
    private var dataBaselayer:  DataBaseLayer!
    private(set) var pageData: [Page]! {
        didSet {
            self.bindPageViewModelToController()
        }
    }
    
    var bindPageViewModelToController : (() -> ()) = {}
    var bookId = ""
    
    let store = EKEventStore()
    
    override init() {
        super.init()
        self.dataBaselayer = DataBaseLayer()
        self.pageData = []
    }
    
    public func saveUserData(firstName: String, lastName: String, email: String, userId: String) {
        dataBaselayer.saveUserData(firstName: firstName, lastName: lastName, email: email, userId: userId)
    }
    
    public func isUserLogedIn() -> Bool {
        return dataBaselayer.auth.currentUser != nil
    }
    
    func signInPressed(em: String, pass: String, completion: @escaping () -> Void) {
        dataBaselayer.auth.signIn(withEmail: em , password: pass) { res, err in
            if let error = err {
                print(error.localizedDescription)
                return
            } else {
                completion()
                print("Signed in ")
            }
        }
    }
    
    func signUpPressed(em: String, pass: String, conPass: String, firstName: String, lastName: String, completion: @escaping () -> ()) {
        dataBaselayer.auth.createUser(withEmail: em, password: pass) { [weak self] response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                completion()
                self?.saveUserData(firstName: firstName, lastName: lastName, email: em, userId: response?.user.uid ?? "")
                print("Signed up")
                
            }
        }
    }
    
    func getAllUserNotes() {
        dataBaselayer.getNotes { [weak self] response in
            self?.pageData.removeAll()
            for (_,y) in response {
                let page = Page(data: y)

                self?.pageData.append(page)
            }
            self?.pageData = self?.pageData.filter({$0.authorId == self?.dataBaselayer.auth.currentUser?.uid})
            self?.pageData = self?.pageData.sorted(by: {$0.date < $1.date}) ?? []
        }
    }
    
    func uploadDrawing(initialDate: Date?, title: String, imageRef: String, documentId: String, image: UIImage, completion: @escaping () -> Void) {
        dataBaselayer.uploadUploadDrawing(initialDate: initialDate, imageRef: imageRef, documentId: documentId, title: title, image: image) {
            completion()
        }
    }
    
    
    
    func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        dataBaselayer.downloadImage(url: url) { image in
            completion(image)
        }
    }
    
    func createNewBook(title: String, initialDate: Date?) {
        dataBaselayer.createNewBook(initialDate: initialDate, title: title) { [weak self]  bookId in
            self?.filterPagesByBook(bookId: bookId)
            self?.bookId = bookId
        }
    }
    
    func createNewTyping(initialDate: Date, documentId: String, title: String, note: String, completion: @escaping () -> Void) {
        dataBaselayer.saveTyping(initialDate: initialDate, documentId: documentId, title: title, note: note) {
            completion()
        }
    }
    
    func filterPagesByBook(bookId: String) {
        self.pageData = self.pageData.filter({$0.bookId == bookId})
    }
    
    func signOut(completion: @escaping () -> ()) {
        dataBaselayer.signOut {
            completion()
        }
    }
    
    func askForPermission() {
        store.requestAccess(to: .reminder) { (granted, error) in
            if let error = error {
                print(error)
                return
            }
        }
    }
    
    func setNoteReminder(date: Date, title: String) {
        askForPermission()
        
        guard let calendar = self.store.defaultCalendarForNewReminders() else { return }
        
        let newReminder = EKReminder(eventStore: store)
        newReminder.calendar = calendar
        newReminder.title = title
        
        newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)

        
        try! store.save(newReminder, commit: true)
    }
    
    func filterAtoZ(orderUp: Bool) {
        
        if orderUp {
            self.pageData = self.pageData.sorted(by: {$0.title > $1.title})
        } else {
            self.pageData = self.pageData.sorted(by: {$0.title < $1.title})
        }
    }
    
    func filterMostRecent(orderUp: Bool) {
        if orderUp {
            self.pageData = self.pageData.sorted(by: { page1, page2 in
                if let fEdit = page1.editedAt, let sEdit = page2.editedAt {
                    return fEdit > sEdit
                } else {
                    return false
                }
            })
        } else {
            self.pageData = self.pageData.sorted(by: { page1, page2 in
                if let fEdit = page1.editedAt, let sEdit = page2.editedAt {
                    return fEdit < sEdit
                } else {
                    return false
                }
            })
        }
    }
    
    func filterAge(orderUp: Bool) {
        if orderUp {
            self.pageData = self.pageData.sorted(by: {$0.date > $1.date})
        } else {
            self.pageData = self.pageData.sorted(by: {$0.date < $1.date})
        }
    }
}
