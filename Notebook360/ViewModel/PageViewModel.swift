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
    
    var pageDataCache: [Page] = []
    
    var bindPageViewModelToController : (() -> ()) = {}
    static public var bookId: String?
    
    let store = EKEventStore()
    
    override init() {
        super.init()
        self.dataBaselayer = DataBaseLayer()
        self.pageData = []
    }
    
    public func saveUserData(firstName: String, lastName: String, email: String, userId: String, completion: @escaping (Bool, String) -> Void) {
        dataBaselayer.saveUserData(firstName: firstName, lastName: lastName, email: email, userId: userId) { pass, msg in
            completion(pass, msg)
        }
    }
    
    public func isUserLogedIn() -> Bool {
        return dataBaselayer.auth.currentUser != nil
    }
    
    func signInPressed(em: String, pass: String, completion: @escaping (Bool, String) -> Void) {
        dataBaselayer.auth.signIn(withEmail: em , password: pass) { res, err in
            if let error = err {
                print(error.localizedDescription)
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Success")
                print("Signed in ")
            }
        }
    }
    
    func showAlert(vc: UIViewController, msg: String, msgBody: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: msg, message: msgBody, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok", style: .default) { _ in
            completion()
        }
        
        alert.addAction(ok)
        
        vc.present(alert, animated: true)
    }
    
    func signUpPressed(em: String, pass: String, conPass: String, firstName: String, lastName: String, completion: @escaping (Bool, String) -> ()) {
        dataBaselayer.auth.createUser(withEmail: em, password: pass) { [weak self] response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false, error.localizedDescription)
            } else {
                self?.saveUserData(firstName: firstName, lastName: lastName, email: em, userId: response?.user.uid ?? "", completion: { pass, msg in
                    if pass {
                        completion(true, "Success")
                    } else {
                        completion(false, "PLEASE CONTACT ADMIN radianceokuzor@gmail.com \nI created your account but your data is missing because \n\(msg)")
                    }
                })
            }
        }
    }
    
    func getAllUserNotes( completion: @escaping () -> Void) {
        dataBaselayer.getNotes { [weak self] response in
            self?.pageData.removeAll()
            for doc in response {
                let page = Page(data: doc)

                self?.pageData.append(page)
                
                print(doc)
            }

            self?.pageData = self?.pageData.sorted(by: {$0.date < $1.date}) ?? []
            self?.pageDataCache = self?.pageData ?? []
            self?.filterPagesByBook(bookId: "all") {
                completion()
            }
        }
    }
    
    func uploadDrawing(initialDate: Date?, title: String, imageRef: String, documentId: String, image: UIImage, completion: @escaping (Bool, String) -> Void) {
        dataBaselayer.uploadUploadDrawing(bookId: Self.bookId, initialDate: initialDate, imageRef: imageRef, documentId: documentId, title: title, image: image) {pass, msg in
            completion(pass, msg)
        }
    }
    
    func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        dataBaselayer.downloadImage(url: url) { image in
            completion(image)
        }
    }
    
    func createNewBook(title: String, initialDate: Date?) {
        dataBaselayer.createNewBook(bookId: Self.bookId, initialDate: initialDate, title: title) { [weak self]  pass, bookId  in
            if pass {
                self?.filterPagesByBook(bookId: bookId) {
                    
                }
                Self.bookId = bookId
            } else {
                // show error here that book never got created
            }
        }
    }
    
    func createNewTyping(initialDate: Date, documentId: String, title: String, note: String, completion: @escaping (Bool, String) -> Void) {
        dataBaselayer.saveTyping(bookId: Singleton.shared.bookId, initialDate: initialDate, documentId: documentId, title: title, note: note) {pass, msg in
            completion(pass, msg)
        }
    }
    
    func filterPagesByBook(bookId: String, completion: @escaping () -> Void) {
        self.pageData = self.pageDataCache.filter({$0.bookId == bookId})
        completion()
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
