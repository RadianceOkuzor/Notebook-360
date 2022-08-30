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
    
    public func saveUserData(firstName: String, lastName: String, email: String) {
        dataBaselayer.saveUserData(firstName: firstName, lastName: lastName, email: email)
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
                self?.saveUserData(firstName: firstName, lastName: lastName, email: em)
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
            self?.pageData = self?.pageData.sorted(by: {$0.date < $1.date}) ?? []
        }
    }
    
    func uploadDrawing(imageRef: String, documentId: String, image: UIImage, completion: @escaping () -> Void) {
        dataBaselayer.uploadUploadDrawing(imageRef: imageRef, documentId: documentId, title: randomString(of: 7), image: image) {
            completion()
        }
    }
    
    func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
    
    func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        dataBaselayer.downloadImage(url: url) { image in
            completion(image)
        }
    }
    
    func createNewBook(title: String) {
        dataBaselayer.createNewBook(title: title) { [weak self]  bookId in
            self?.filterPagesByBook(bookId: bookId)
            self?.bookId = bookId
        }
    }
    
    func createNewTyping(documentId: String, title: String, note: String, completion: @escaping () -> Void) {
        dataBaselayer.saveTyping(documentId: documentId, title: title, note: note) {
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
}
