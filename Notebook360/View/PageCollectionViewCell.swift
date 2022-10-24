//
//  PageCollectionViewCell.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit
import RichEditorView

class PageCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var bkGdImage: UIImageView!
    @IBOutlet weak var htmlView: RichEditorView!
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        htmlView.html = title. ?? ""
//
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    func setupView() {
        htmlView.isHidden = true
    }
    
    func unSetupView() {
        htmlView.isHidden = false
        bkGdImage.image = UIImage(imageLiteralResourceName: "paperbkg")
    }
    
}
