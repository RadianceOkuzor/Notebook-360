//
//  TypeVC.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import RichEditorView

class TypeVC: UIViewController {
    
    var page = Page(data: [:])
    
    var pageVM: PageViewModel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var htmlView: RichEditorView!
    
    let toolbar = RichEditorToolbar()
    
    var noteToBeSave = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageVM = PageViewModel()
        
//        additionalSafeAreaInsets = .init(top: 6, left: 12, bottom: 0, right: 12)
        htmlView.translatesAutoresizingMaskIntoConstraints = false
        htmlView.delegate = self
        htmlView.editingEnabled = true
        htmlView.placeholder = "Press to start typing"
        
        
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        let greenColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "🟢") { toolbar in
            toolbar.editor?.setTextColor(.green)
            return
        }
        let blueColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "🔵") { toolbar in
            toolbar.editor?.setTextColor(.blue)
            return
        }
        let redColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "🔴") { toolbar in
            toolbar.editor?.setTextColor(.red)
            return
        }
        
        let blackColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "⚫️") { toolbar in
            toolbar.editor?.setTextColor(.black)
            return
        }
        
        toolbar.options = RichEditorDefaultOption.all
        toolbar.options.append(blueColor)
        toolbar.options.append(redColor)
        toolbar.options.append(greenColor)
        toolbar.options.append(blackColor)
        toolbar.editor = htmlView
        toolbar.backgroundColor = .white
        
        htmlView.inputAccessoryView = toolbar
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        htmlView.html = page.notes
    }
    
    @IBAction func donePrsd(_ sender: Any) {
        if !noteToBeSave.isEmpty {
            let title = "<H3> Type Note </H3> \n\(Date.now) "
            if page.title == "" {
                page.title = title
            }
            pageVM.createNewTyping(initialDate: page.date, documentId: page.id, title: page.title, note: noteToBeSave) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
                
            }
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func reminderPrsd(_ sender: Any) {
        //do reminder
        view.endEditing(true)
        datePicker.isHidden.toggle()
        
        if datePicker.isHidden {
            pageVM.setNoteReminder(date: datePicker.date, title: page.title)
        }
    }

}

extension TypeVC: RichEditorDelegate, RichEditorToolbarDelegate  {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        // This is meant to act as a text cap
//        if content.count > 40000 {
//            editor.html = prevText
//        } else {
//            prevText = content
//        }
        noteToBeSave = content
    }
    
    func richEditorTookFocus(_ editor: RichEditorView) {
        
    }
    
    func richEditorLostFocus(_ editor: RichEditorView) {
        
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        //
    }
}
