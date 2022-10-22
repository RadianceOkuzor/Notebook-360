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
    
    var pageVM: PageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        self.pageVM = PageViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !page.drawing.isEmpty {
            imageBKGD.isHidden = false
            pageVM.downloadImage(url: page.imageRef) { image in
                DispatchQueue.main.async {
                    self.imageBKGD.image = image
                }
            }
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
        //
    }
    
    func saveDrawingToPhotoLibrary() {
        guard let drawnImage = drawableView.image else {return }
        pageVM.uploadDrawing(initialDate: page.date, title: page.title, imageRef: page.imageRef, documentId: page.id, image: drawnImage) {pass, msg in
            if pass {
                self.dismiss(animated: true)
            } else {
                self.pageVM.showAlert(vc: self, msg: "Sorry failed to save", msgBody: "") {
                    self.dismiss(animated: true)
                }
            }
        }
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
