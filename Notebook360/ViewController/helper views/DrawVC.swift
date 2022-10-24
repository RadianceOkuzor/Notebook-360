//
//  DrawVC.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import DrawableView

class DrawVC: UIViewController {
    
    @IBOutlet var drawableView: DrawableView! {
      didSet {
        drawableView.delegate = self
        drawableView.strokeColor = .blue
        drawableView.strokeWidth = 12.0
//        drawableView.transparency = 1.0
      }
    }
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageBKGD: UIImageView!
    
    
    let picker = UIColorPickerViewController()

    var page = Page()
    var cPageIndex = Int()
    
    var pageVM: PageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        self.pageVM = PageViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !(page.drawing?.isEmpty ?? false) {
//            drawableView.image = UIImage(data: page.drawing ?? .init())
            drawableView.updateImage(image: UIImage(data: page.drawing ?? .init()) ?? .init())
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        if drawableView.containsDrawing {
            saveDrawingToPhotoLibrary()
        } else {
            
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        drawableView.undo()
    }
    
    @IBAction func redoButtonTapped(_ sender: Any) {
        drawableView.undo()
    }
    
    @IBAction func changeColorTapped(_ sender: Any) {
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func sliderPressed(_ sender: UISlider) {
        drawableView.strokeWidth = CGFloat(sender.value)
    }
    
    @IBAction func changeFontTapped(_ sender: Any) {
//        drawableView.strokeWidth = width.value
        slider.isHidden.toggle()
    }
}

extension DrawVC: DrawableViewDelegate {
    func setDrawing(_ isDrawing: Bool) {
        if isDrawing {
//            imageBKGD.image = drawableView.image
        }
    }
    
    func saveDrawingToPhotoLibrary() {
        guard let drawnImage = drawableView.image else {return }
        if page.drawing == nil {
            // save new drawing
            page.drawing = drawnImage.jpegData(compressionQuality: 0.2)
            if let book = Singleton.shared.coreBooks.first {
                let cpage = DataManager.shared.corePage(page: page, cBook: book)
                DataManager.shared.save()
            }
        } else {
            // update current drawing
            if let book = Singleton.shared.coreBooks.first {
                DataManager.shared.updateCorePage(book: book, index: cPageIndex, notes: nil, drawing: drawnImage.pngData(), isNotes: false)
            }
        }
        self.dismiss(animated: true)
    }
}

extension DrawVC: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.view.backgroundColor = viewController.selectedColor
        self.drawableView.strokeColor = viewController.selectedColor
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    }
}
