//
//  ViewController.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var drawTypeBtn: UIButton!
    @IBOutlet weak var drawBtn: UIButton!
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var newBookBtn: UIButton!
    // filter buttons
    @IBOutlet weak var createdAtFilterBtn: UIButton!
    @IBOutlet weak var editedAtFilterBtn: UIButton!
    @IBOutlet weak var aToZFilterBtn: UIButton!
    
    
    
    var pageVM: PageViewModel!
    var pages = [Page]()
    var selectedPage = Page(data: [:])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.pageVM = PageViewModel()
        callToVMForUIUpdate()
        pageVM.getAllUserNotes()
        
        collection.keyboardDismissMode = .onDrag
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuBtn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        drawTypeBtn.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
        typeBtn.setImage(UIImage(systemName: "t.circle"), for: .normal)
        drawBtn.setImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
        newBookBtn.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        
        collection.reloadData()
    }
    
    
    @IBAction func signOutPrsd(_ sender: Any) {
        // sign out
        pageVM.signOut {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func menuPrsd(_ sender: Any) {
        openCloseMenu()
    }
    
    @IBAction func drawTypePrsd(_ sender: UIButton) {
        openCloseMenu()
        selectedPage = Page(data: [:])
        switch sender.accessibilityIdentifier {
        case "DrawAndType":
            performSegue(withIdentifier: "showDrawFromHome", sender: self)
        case "Draw":
            performSegue(withIdentifier: "showDrawFromHome", sender: self)
        case "Type":
            performSegue(withIdentifier: "showTypeFromHome", sender: self)
        case "newBook":
            // refresh page list
            showAlert { self.pageVM.createNewBook(title: $0) }
        default:
            //
            ()
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        openCloseFilterBtns()
    }
    
    
    func callToVMForUIUpdate() {
        self.pageVM.bindPageViewModelToController = {self.updateDataSource()}
    }
    
    @IBAction func searchField(_ sender: Any) {
        
        
    }
    
    @IBAction func searchFieldEnd(_ sender: Any) {
        
    }
    
    @IBAction func aToZpressed(_ sender: Any) {
        openCloseFilterBtns()
    }
    
    @IBAction func createdAtPrsd(_ sender: Any) {
        openCloseFilterBtns()
    }
    
    @IBAction func editFilterPrsd(_ sender: Any) {
       openCloseFilterBtns()
    }
    
    func openCloseFilterBtns() {
        UIView.animate(withDuration: 1, delay: 0.0) {
            self.createdAtFilterBtn.isHidden.toggle()
            self.editedAtFilterBtn.isHidden.toggle()
            self.aToZFilterBtn.isHidden.toggle()
        }
    }
    
    func openCloseMenu() {
        UIView.animate(withDuration: 1, delay: 0.0) {
            self.drawTypeBtn.isHidden.toggle()
            self.drawBtn.isHidden.toggle()
            self.typeBtn.isHidden.toggle()
            self.newBookBtn.isHidden.toggle()
        }
    }
    
    func updateDataSource() {
        pages.removeAll()
        pages = pageVM.pageData
        DispatchQueue.main.async {
            // Updat UI here
            self.collection.reloadData()
            print(self.pages)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TypeVC {
            vc.page = selectedPage
        }
        
        if let vc = segue.destination as? DrawVC {
            vc.page = selectedPage
        }
        
    }
    
    func showAlert(completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: "Enter Book Title", message: "", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Book title"
        let ok = UIAlertAction(title: "create", style: .default) {_ in
            let bookTitle = alert.textFields?.first?.text ?? ""
            completion(bookTitle)
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .destructive)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePageCell", for: indexPath) as! PageCollectionViewCell
        if pages[indexPath.row].pageType == .book {
            cell.unSetupView()
            cell.htmlView.html = "<h3> \(pages[indexPath.row].title) </h3>"
        } else if pages[indexPath.row].pageType == .draw  {
            pageVM.downloadImage(url: pages[indexPath.row].imageRef) { image in
                DispatchQueue.main.async {
                    cell.bkGdImage.image = image
                    cell.setupView()
                }
            }
        } else if pages[indexPath.row].pageType == .type {
            cell.unSetupView()
            cell.htmlView.html = pages[indexPath.row].notes
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPage = pages[indexPath.row]
        if pages[indexPath.row].pageType == .type {
            self.performSegue(withIdentifier: "showTypeFromHome", sender: self)
        } else if pages[indexPath.row].pageType == .draw || pages[indexPath.row].pageType == .drawType {
            self.performSegue(withIdentifier: "showDrawFromHome", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100.0, height: 150.0)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
    }
}

