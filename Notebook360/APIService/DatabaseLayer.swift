//
//  DatabaseLayer.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

public class DataBaseLayer : NSObject {
    
    var ref: DatabaseReference!
    
    let db = Firestore.firestore()
    
    let auth = Auth.auth()
    
    var documentID: String = ""
    
    func setup() {
        ref = Database.database().reference()
        
        documentID = db.collection("Users").document().documentID
    }
    
    public func saveUserData(firstName: String, lastName: String, email: String, userId: String) {
        setup()
        
        db.collection("Users").addDocument(data: ["firstName":firstName,
                                                  "lastName":lastName,
                                                  "email":email]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: ")
            }
        }
        
        ref.child("Users").child(userId).updateChildValues(
            ["firstName":firstName,
             "lastName":lastName,
             "email":email,
             "id":userId]) { error, snapShot in
                 if error != nil {
                     
                 } else {
                 }
             }
    }
    
    func getNotes(bookId: String = "", completion: @escaping ([String:[String:Any]]) -> ()) {
        ref = Database.database().reference()
        
        _ = ref.child("Notes").observe(.value) { snapShot in
            let d = snapShot.value as? [String:[String:Any]] ?? [:]
            
            completion(d)
        } withCancel: { error in
            //
            print(error)
        }
    }
    
    func uploadUploadDrawing(initialDate: Date?, imageRef: String, documentId: String, title: String, image: UIImage, completion: @escaping () -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        var imageRef1 = "\(randomString(of: 7))_notes.png"
        if imageRef != "" {
            imageRef1 = imageRef
        }
        
        let storageRef = Storage.storage().reference().child(imageRef1)
        if let uploadData = image.pngData() {
            storageRef.putData(uploadData, metadata: metadata) { metaData, error in
                if error == nil {
                    storageRef.downloadURL { url, err in
                        if err == nil {
                            print("Upload successful\n\n\n\nupload located at \n\(url?.absoluteString ?? "" )")
                            self.saveDrawing(initialDate: initialDate, documentId: documentId, title: title, url: url, imageRef: imageRef1) {
                                completion()
                            }
                        } else {
                            print(err?.localizedDescription ?? "unknown error for upload of image")
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "unknown error for upload of image")
                }
            }
        }
     }
    
    func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        let islandRef = Storage.storage().reference().child(url)

        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
              print(error.localizedDescription)
          } else {
            // Data for "images/island.jpg" is returned
              if let image = UIImage(data: data!) {
                  completion(image)
              } else {
                  completion(nil)
              }
          }
        }
    }
    
    func saveDrawing(initialDate: Date?, documentId: String, title: String, url: URL?, imageRef: String, completion: @escaping () -> Void) {
        
        setup()
        
        var initialDate: Date?
        
        if documentId != "" {
            documentID = documentId
            initialDate = Date.now
        }
        
       let docData: [String: Any] = [
           "title": title,
           "date": "\(initialDate ?? Date.now)",
           "editedAt" : "\(Date.now)",
           "id": documentID,
           "noteType": "draw",
           "drawUrl": url?.absoluteString ?? "",
           "imageRef": imageRef,
           "authorId":Auth.auth().currentUser?.uid ?? "nil",
           "bookId": ""
       ]
       
       var ref: DatabaseReference!
       
       ref = Database.database().reference()
       
       ref.child("Notes").child(documentID).updateChildValues(docData) { error, snapShot in
           if let err = error {
               print(err.localizedDescription)
           } else {
               completion()
           }
       }
    }
    
    func saveTyping(initialDate: Date?, documentId: String, title: String, note: String, completion: @escaping () -> Void) {
        
        setup()
        
        if !documentId.isEmpty {
            documentID = documentId
        }
        
       let docData: [String: Any] = [
           "title": title,
           "date": "\(initialDate ?? Date.now)",
           "editedAt" : "\(Date.now)",
           "id": documentID,
           "noteType": "type",
           "note": note,
           "authorId":Auth.auth().currentUser?.uid ?? "nil",
           "bookId": ""
       ]
       
       var ref: DatabaseReference!
       
       ref = Database.database().reference()
       
       ref.child("Notes").child(documentID).updateChildValues(docData) { error, snapShot in
           if let err = error {
               print(err.localizedDescription)
               completion()
           } else {
               completion()
           }
       }
    }
    
    func createNewBook(initialDate: Date?, title: String, completion: @escaping (String) -> Void) {
        
        setup()
        
       let docData: [String: Any] = [
           "title": title,
           "date": "\(initialDate ?? Date.now)",
           "id": documentID,
           "editedAt" : "\(Date.now)",
           "noteType": "book",
           "authorId":Auth.auth().currentUser?.uid ?? "nil",
           "bookId": ""
       ]
       
       var ref: DatabaseReference!
       
       ref = Database.database().reference()
       
       ref.child("Notes").child(documentID).updateChildValues(docData) { error, snapShot in
           if let err = error {
               print(err.localizedDescription)
           } else {
               completion(self.documentID)
           }
       }
    }
    
    func signOut(completion: @escaping () -> ()) {
        do {
          try Auth.auth().signOut()
            completion()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
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
}
