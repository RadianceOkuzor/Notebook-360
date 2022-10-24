//
//  DrawTypeViewController.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 10/23/22.
//

import UIKit

class DrawTypeViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var sliderBrush: UISlider!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var changeBrushWidthView: UIStackView!
    
    @IBOutlet weak var labelBrush: UILabel!
    
    @IBOutlet weak var eraserBtn: UIButton!
    @IBOutlet weak var eraserBtnImg: UIImageView!
    
    var eraserBtnIsOn: Bool = false
    
    var cPage = CorePage()
    var page = Page()
    var cPageIndex = Int()
    
    var erasedColor = UIColor.black
    var erasedWidth: CGFloat = 10
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainImageView.image = UIImage(data: page.drawing ?? .init())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
              let settingsController = navController.topViewController as? SettingsViewController else {
            return
        }
        settingsController.delegate = self
        settingsController.brush = brushWidth
        settingsController.opacity = opacity
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        settingsController.red = red
        settingsController.green = green
        settingsController.blue = blue
    }
    
    @IBAction func setEraser(_ sender: Any) {
        
        eraserBtnIsOn = eraserBtnIsOn ? false : true
        if eraserBtnIsOn {
            erasedColor = color
            erasedWidth = brushWidth
            
            color = self.view.backgroundColor ?? .black
            brushWidth = 14
            eraserBtnImg.image = UIImage(named: "eraserOn")
//            eraserBtn.setImage(UIImage(named: "eraserOn"), for: .normal)
        } else {
            color = erasedColor
            brushWidth = erasedWidth
            eraserBtnImg.image = UIImage(named: "eraser")
        }
    }
    
    @IBAction func changeBrushWidthPressed(_ sender: Any) {
        changeBrushWidthView.isHidden = changeBrushWidthView.isHidden ? false : true
    }
    @IBAction func sharePressed(_ sender: Any) {
//        guard let image = mainImageView.image else {
//            return
//        }
//        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
//        present(activity, animated: true)
        
        guard let _ = mainImageView.image else { self.dismiss(animated: true); return }
        
        saveDrawing()
    }
    
    func drawPreview() {
      UIGraphicsBeginImageContext(previewImageView.frame.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        return
      }
      
      context.setLineCap(.round)
      context.setLineWidth(brushWidth)
//      context.setStrokeColor(color)
      context.move(to: CGPoint(x: 45, y: 45))
      context.addLine(to: CGPoint(x: 45, y: 45))
      context.strokePath()
      previewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }
    
    @IBAction func brushWidthChanged(_ sender: UISlider) {
      brushWidth = CGFloat(sender.value)
      labelBrush.text = String(format: "%.1f", brushWidth)
      drawPreview()
    }
    
    @IBAction func pencilPressed(_ sender: UIButton) {
//        guard let pencil = Pencil(tag: sender.tag) else {
//            return
//        }
//        color = pencil.color
//        if pencil == .eraser {
//            opacity = 1.0
//        }
        
        let picker = UIColorPickerViewController()

        // Setting the Initial Color of the Picker
        picker.selectedColor = self.view.backgroundColor!

        // Setting Delegate
        picker.delegate = self

        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        context.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
        
        changeBrushWidthView.isHidden = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    func saveDrawing() {
        guard let drawnImage = mainImageView.image else {return }
        if page.drawing == nil {
            // save new drawing
            page.drawing = drawnImage.jpegData(compressionQuality: 0.2)
            if let book = Singleton.shared.coreBooks.first {
                let cpage = DataManager.shared.corePage(page: page, cBook: book)
                DataManager.shared.save()
            }
        } else {
            // update current drawing
            cPage.drawing = drawnImage.jpegData(compressionQuality: 0.2)
            cPage.dateEdited = Date.now
            DataManager.shared.save()
//            if let book = Singleton.shared.coreBooks.first {
//                DataManager.shared.updateCorePage(book: book, index: cPageIndex, notes: nil, drawing: drawnImage.jpegData(compressionQuality: 0.2), isNotes: false)
//            }
        }
        self.dismiss(animated: true)
    }
}

extension DrawTypeViewController: SettingsViewControllerDelegate {
    func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
        brushWidth = settingsViewController.brush
        opacity = settingsViewController.opacity
        color = UIColor(red: settingsViewController.red,
                        green: settingsViewController.green,
                        blue: settingsViewController.blue,
                        alpha: opacity)
        dismiss(animated: true)
    }
}

extension DrawTypeViewController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
        color = viewController.selectedColor
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            
    }
}
