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
    @IBOutlet weak var drawTypeBtn: UIView!
    @IBOutlet weak var drawBtn: UIView!
    @IBOutlet weak var typeBtn: UIView!
    @IBOutlet weak var newBookBtn: UIView!
    // filter buttons
    @IBOutlet weak var createdAtFilterBtn: UIButton!
    @IBOutlet weak var editedAtFilterBtn: UIButton!
    @IBOutlet weak var aToZFilterBtn: UIButton!
    @IBOutlet weak var showAllFilterBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var menuView: UIView!
    
    
    var pageVM: PageViewModel!
    var pages = [Page]()
    var corePages = [CorePage]()
    var selectedPage = Page()
    var corePage = CorePage()
    
    var filtertAtoZUp = false
    var filterAgeUp = false
    var filterRecentUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.pageVM = PageViewModel()
//        callToVMForUIUpdate()
//        pageVM.getAllUserNotes() {
//            self.collection.reloadData()
//        }
        
        if let book = Singleton.shared.coreBooks.first {
            corePages = DataManager.shared.corePages(coreBook: book)
        }
        
        collection.keyboardDismissMode = .onDrag
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        corePages.removeAll()
        if let book = Singleton.shared.coreBooks.first {
            corePages = DataManager.shared.corePages(coreBook: book)
        }
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
    @IBOutlet weak var menuBtnImage: UIImageView!
    
    @IBAction func menuPrsd(_ sender: Any) {
        openCloseMenu()
        let angle = newBookBtn.isHidden ? CGFloat.pi/4 : -(CGFloat.pi/4)
        UIView.animate(withDuration: 0.5) {
            self.menuBtnImage.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    @IBAction func drawTypePrsd(_ sender: UIButton) {
        openCloseMenu()
        switch sender.accessibilityIdentifier {
        case "DrawAndType":
            showAlert(type: .drawType) { [weak self] title in
                self?.selectedPage = Page()
                self?.selectedPage.title = title
                self?.selectedPage.pageType = .drawType
                self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
        case "Draw":
            showAlert(type: .draw) { [weak self]  title in
                self?.selectedPage.title = title
                self?.selectedPage.pageType = .draw
                self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
        case "Type":
            self.selectedPage = Page()
            self.selectedPage.pageType = .type
            performSegue(withIdentifier: "showTypeFromHome", sender: self)
        case "newBook":
            // refresh page list
            showAlert(type: .book) {
                self.selectedPage.pageType = .book
                self.pageVM.createNewBook(title: $0, initialDate: nil)
                let cbook = DataManager.shared.coreBook(book: .init(id: UUID().uuidString, title: $0))
                Singleton.shared.coreBooks.append(cbook)
                DataManager.shared.save()
                
                // Clean the pages and show pages array for this book
//                Singleton.shared.currentBook = cbook
            }
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
//        filtertAtoZUp.toggle()
        pageVM.filterAtoZ(orderUp: filtertAtoZUp)
        collection.reloadData()
        
        let title = filtertAtoZUp ? "A ↗ Z" : "A ↘︎ Z"
        
        aToZFilterBtn.setTitle(title, for: .normal)
    }
    
    @IBAction func allNotesFilterPrsd(_ sender: Any) {
        openCloseFilterBtns()
        
        self.pageVM.filterPagesByBook(bookId: "all") {
            self.collection.reloadData()
        }
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
        UIView.animate(withDuration: 0.25, delay: 0.0) {
            self.createdAtFilterBtn.isHidden.toggle()
            self.editedAtFilterBtn.isHidden.toggle()
            self.aToZFilterBtn.isHidden.toggle()
            self.showAllFilterBtn.isHidden.toggle()
        }
    }
    
    func openCloseMenu() {
        UIView.animate(withDuration: 0.25, delay: 0.0) {
            self.newBookBtn.isHidden.toggle()
            self.typeBtn.isHidden.toggle()
            self.drawBtn.isHidden.toggle()
            self.drawTypeBtn.isHidden.toggle()
        }
    }
    
    func updateDataSource() {
        pages.removeAll()
        pages = pageVM.pageData
        DispatchQueue.main.async {
            // Updat UI here
            self.collection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TypeVC {
            vc.page = selectedPage
            vc.cPage = corePage
        }
        
        if let vc = segue.destination as? DrawTypeViewController {
            vc.page = selectedPage
            vc.cPage = corePage
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
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
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
        return corePages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePageCell", for: indexPath) as! PageCollectionViewCell
        if corePages[indexPath.row].pageType == "book" {
            cell.unSetupView()
            cell.htmlView.html = "<h3> \(corePages[indexPath.row].title ?? "") </h3>"
        } else if corePages[indexPath.row].pageType == "draw" || corePages[indexPath.row].pageType == "drawType"   {
            cell.bkGdImage.image = UIImage(data: corePages[indexPath.row].drawing ?? .init())
            cell.setupView()
//            pageVM.downloadImage(url: pages[indexPath.row].imageRef) { image in
//                DispatchQueue.main.async {
//                    cell.bkGdImage.image = image
//                    cell.setupView()
//                }
//            }
        } else if corePages[indexPath.row].pageType == "type" {
            cell.unSetupView()
            cell.htmlView.html = corePages[indexPath.row].notes ?? ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        DataManager.shared.deletePage(corePage: corePages[indexPath.row])
        selectedPage = Page(cPage: corePages[indexPath.row])
        corePage = corePages[indexPath.row]

        if corePages[indexPath.row].pageType == "type" {
            self.performSegue(withIdentifier: "showTypeFromHome", sender: self)
        } else if corePages[indexPath.row].pageType == "draw" || corePages[indexPath.row].pageType == "drawType" {
            self.performSegue(withIdentifier: "showDrawFromHome", sender: self)
        } else if corePages[indexPath.row].pageType == "book" {
//            Singleton.shared.bookId = pages[indexPath.row].id
//            self.pageVM.filterPagesByBook(bookId: pages[indexPath.row].id) {
//                self.collection.reloadData()
//            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100.0, height: 150.0)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
//        self.pages = self.pageVM.pageData.filter({$0.notes.contains(textField.text ?? "")})
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
