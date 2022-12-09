//
//  TypeVC.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import RichEditorView
import SwiftUI

class TypeVC: UIViewController {
    
    var page = Page()
    
    var cPage = CorePage()
    var cBook = CoreBook()
    var cPageIndex = Int()
    
    var pageVM: PageViewModel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var htmlView: RichEditorView!
    
    @IBOutlet weak var setTimerBtn: UIButton!
    
    var toolbar = RichEditorToolbar()
    
    var textFont = 17
    
    var noteToBeSave = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageVM = PageViewModel()
        htmlView.translatesAutoresizingMaskIntoConstraints = false
        htmlView.delegate = self
        htmlView.editingEnabled = true
        htmlView.placeholder = "Press to start typing"
        
        toolbar.editor?.setFontSize(textFont)
        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        let reduceFont = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "▽") { toolbar in
            self.textFont -= 1
            toolbar.editor?.setFontSize(self.textFont)
            return
        }
        let increaseFont = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "▲") { toolbar in
            self.textFont += 1
            toolbar.editor?.setFontSize(self.textFont)
            return
        }
        let setColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "🎨") { toolbar in
            let picker = UIColorPickerViewController()

            // Setting the Initial Color of the Picker
            picker.selectedColor = self.view.backgroundColor!

            // Setting Delegate
            picker.delegate = self

            // Presenting the Color Picker
            self.present(picker, animated: true, completion: nil)
            return
        }
        
        let blackColor = RichEditorOptionItem(image: UIImage(named: "Pick Color"), title: "⚫️") { toolbar in
            toolbar.editor?.setTextColor(.black)
            return
        }
        
        toolbar.options =  [RichEditorDefaultOption.header(1), RichEditorDefaultOption.header(3), RichEditorDefaultOption.bold, RichEditorDefaultOption.italic, RichEditorDefaultOption.underline, RichEditorDefaultOption.strike, RichEditorDefaultOption.unorderedList, RichEditorDefaultOption.orderedList, RichEditorDefaultOption.indent, RichEditorDefaultOption.outdent, RichEditorDefaultOption.alignLeft, RichEditorDefaultOption.alignCenter, RichEditorDefaultOption.alignRight]
        toolbar.options.append(setColor)
        toolbar.options.append(increaseFont)
        toolbar.options.append(reduceFont)
        toolbar.editor = htmlView
        toolbar.backgroundColor = .darkGray
        
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
            if page.notes.isEmpty {
                // new note save here
                page.notes = noteToBeSave
                let _ = DataManager.shared.corePage(page: page, cBook: cBook)
                DataManager.shared.save()
                self.dismiss(animated: true)
            }
            if page.notes != noteToBeSave {
                // note changes update here
                cPage.notes = noteToBeSave
                cPage.dateEdited = Date.now
                DataManager.shared.updateCorePage(book: cPage.book ?? .init(), index: cPageIndex, notes: noteToBeSave, drawing: nil, isNotes: true)
                DataManager.shared.save()
            }
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func reminderPrsd(_ sender: Any) {
        //do reminder
        view.endEditing(true)
        datePicker.isHidden.toggle()
        setTimerBtn.setTitle(datePicker.isHidden ? "Set Timer" : "Save Timer" , for: .normal)
        if datePicker.isHidden {
            pageVM.setNoteReminder(date: datePicker.date, title: page.title)
        }
    }

}

extension TypeVC: RichEditorDelegate, RichEditorToolbarDelegate  {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
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

extension TypeVC: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        toolbar.editor?.setTextColor(viewController.selectedColor)
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            
    }
}
