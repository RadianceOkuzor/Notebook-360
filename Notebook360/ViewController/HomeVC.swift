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
    @IBOutlet weak var searchTextField: UITextField!
    
    
    
    var pageVM: PageViewModel!
    var pages = [Page]()
    var selectedPage = Page(data: [:])
    
    var filtertAtoZUp = false
    var filterAgeUp = false
    var filterRecentUp = false

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
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuBtn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        drawTypeBtn.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
        typeBtn.setImage(UIImage(systemName: "t.circle"), for: .normal)
        drawBtn.setImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
        newBookBtn.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        
        collection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchTextField.text = ""
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
        switch sender.accessibilityIdentifier {
        case "DrawAndType":
            showAlert(type: .drawType) { [weak self] title in
                self?.selectedPage = Page(data: [:])
                self?.selectedPage.title = title
                self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
        case "Draw":
            showAlert(type: .draw) { [weak self]  title in
                self?.selectedPage.title = title
                self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
        case "Type":
            performSegue(withIdentifier: "showTypeFromHome", sender: self)
        case "newBook":
            // refresh page list
            showAlert(type: .book) { self.pageVM.createNewBook(title: $0, initialDate: nil) }
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
        filtertAtoZUp.toggle()
        pageVM.filterAtoZ(orderUp: filtertAtoZUp)
        collection.reloadData()
        
        let title = filtertAtoZUp ? "A ↗ Z" : "A ↘︎ Z"
        
        aToZFilterBtn.setTitle(title, for: .normal)
    }
    
    @IBAction func createdAtPrsd(_ sender: Any) {
        openCloseFilterBtns()
        pageVM.filterAge(orderUp: filterAgeUp)
        collection.reloadData()
        filterAgeUp.toggle()
        
        let title = filterAgeUp ? "Created  At  ↗" : "Created  At  ↘︎"
        
        createdAtFilterBtn.setTitle(title, for: .normal)
    }
    
    @IBAction func editFilterPrsd(_ sender: Any) {
        openCloseFilterBtns()
        pageVM.filterMostRecent(orderUp: filterRecentUp)
        collection.reloadData()
        filterRecentUp.toggle()
        
        let title = filterRecentUp ? "Recently Edited ↗" : "Recently Edited ↘︎"
        editedAtFilterBtn.setTitle(title, for: .normal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        self.pages = self.pageVM.pageData.filter({$0.notes.contains(textField.text ?? "")})
        collection.reloadData()
        if textField.text == "" {
            self.pages = self.pageVM.pageData
        }

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
    
    func showAlert(type: PageType, completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: "Enter \(type.rawValue) title", message: "", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "\(type.rawValue) title"
        let ok = UIAlertAction(title: "create", style: .default) {_ in
            let bookTitle = alert.textFields?.first?.text ?? ""
            completion(bookTitle)
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .destructive)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
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
        self.pages = self.pageVM.pageData.filter({$0.notes.contains(textField.text ?? "")})
    }
}

