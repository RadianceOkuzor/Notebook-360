//
//  ViewController.swift
//  Notebook360
//
//  Created by Radiance Okuzor on 8/29/22.
//

import UIKit

class HomeVC: UIViewController, UIGestureRecognizerDelegate {
    
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
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var bookTitle: UILabel!
    //Show Side Bar
    @IBOutlet weak var sideBarMenuViewBG: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideBarMenuView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var sideMenuLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var pageVM: PageViewModel!
    var pages = [Page]()
    var corePages = [CorePage]()
    var coreBook = CoreBook()
    var corePagesPreFilter = [CorePage]()
    var selectedPage = Page()
    var cPageIndex = Int()
    var corePage = CorePage()
    var filtertAtoZUp = false
    var filterAgeUp = false
    var filterRecentUp = false
    var bookIndex = [0]
    var rowType = [RowType]()
    var allRowTypes = [RowType]()
    var allRowTypesPreSearchState = [RowType]()
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection.keyboardDismissMode = .onDrag
        
        navigationItem.searchController = searchController
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sideBarMenuView.translatesAutoresizingMaskIntoConstraints = false
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(tap))
        sideBarMenuViewBG.addGestureRecognizer(tapOut)
        
        sideMenuLeftConstraint.constant = view.frame.maxX
        
        ressetView()
    }
    
    @objc func tap() {
        showSideBarMenu()
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        if bookIndex.count > 1 {
            bookIndex.removeLast()
            ressetView()
        }
    }
    
    func animateSideMenu() {
        sideMenuLeftConstraint.constant = (self.sideBarMenuViewBG.layer.opacity == 0.3) ? view.frame.maxX : 122
    
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showSideBarMenu() {
        animateSideMenu()

        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.sideBarMenuViewBG.layer.opacity = (self.sideBarMenuViewBG.layer.opacity == 0.3) ? 0 : 0.3
        }) { bool in
            
        }
    }
    
    func ressetView() {
        let cBooks = DataManager.shared.coreBooks()
        coreBook = cBooks[bookIndex.last ?? 0]
        corePages = DataManager.shared.corePages(coreBook: coreBook)
        
        rowType.removeAll()
        
        for x in corePages {
            rowType.insert(.page(x), at: 0)
        }
        let bookIds = DataManager.shared.bookIds(coreBook: coreBook)
        for x in DataManager.shared.coreBooks() {
            
            if bookIds.contains(where: {$0.string == x.id}) {
                rowType.insert(.book(x), at: 0)
            }
        }
        collection.reloadData()
        
        getAllBooksAndPages()
        
        UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
            self?.backBtn.isHidden = self?.bookIndex.last == 0 ? true : false
            self?.bookTitle.text = self?.bookIndex.last == 0 ? "360 NoteBooks" : self?.coreBook.title ?? "NoteBook"
        }
    }
    
    func getAllBooksAndPages() {
        allRowTypes.removeAll()
        for x in DataManager.shared.coreBooks() {
            allRowTypes.insert(.book(x), at: 0)
            
            for y in DataManager.shared.corePages(coreBook: x) {
                allRowTypes.insert(.page(y), at: 0)
            }
        }
        allRowTypesPreSearchState = allRowTypes
        tableView.reloadData()
    }
    
    
    @IBAction func signOutPrsd(_ sender: Any) {
        // sign out
//        pageVM.signOut {
//            self.dismiss(animated: true)
//        }
    }
    
    @IBOutlet weak var menuBtnImage: UIImageView!
    
    @IBAction func menuPrsd(_ sender: Any) {
        openCloseMenu()
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
                self?.selectedPage = Page()
                self?.selectedPage.title = title
                self?.selectedPage.pageType = .draw
                self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
        case "Type":
            self.selectedPage = Page()
            self.selectedPage.pageType = .type
            performSegue(withIdentifier: "showTypeFromHome", sender: self)
        case "newBook": ()
            showAlert(type: .book) { [weak self]  string in
                let cbook = DataManager.shared.coreBook(book: .init(id: UUID().uuidString, title: string, bookIds: []))
                DataManager.shared.updateCoreBookBookList(book: self?.coreBook ?? .init(), idToAdd: cbook.id ?? "null")
                DataManager.shared.save()
                let index = DataManager.shared.coreBooks().firstIndex(where: {$0 == cbook})
                self?.bookIndex.append(index ?? 0)
                self?.ressetView()
            }
        default:
            //
            ()
        }
    }
    
    @IBAction func showSideBarMenu(_ sender: Any) {
        self.showSideBarMenu()
        getAllBooksAndPages()
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
        
        if filtertAtoZUp {
            corePages = corePages.sorted(by: {$0.title ?? "" > $1.title ?? ""})
        } else {
            corePages = corePages.sorted(by: {$0.title ?? "" < $1.title ?? ""})
        }
        
        collection.reloadData()
        
        let title = filtertAtoZUp ? "A ↗ Z" : "A ↘︎ Z"
        
        aToZFilterBtn.setTitle(title, for: .normal)
        filtertAtoZUp.toggle()
    }
    
    @IBAction func allNotesFilterPrsd(_ sender: Any) {
        openCloseFilterBtns()
        
        corePages.removeAll()
        corePages = corePagesPreFilter
        collection.reloadData()
//        self.pageVM.filterPagesByBook(bookId: "all") {
//            self.collection.reloadData()
//        }
    }
    
    @IBAction func createdAtPrsd(_ sender: Any) {
        openCloseFilterBtns()
//        pageVM.filterAge(orderUp: filterAgeUp)
        
        if filterAgeUp {
            corePages = corePages.sorted(by: {$0.dateCreated ?? .now > $1.dateCreated ?? .now})
        } else {
            corePages = corePages.sorted(by: {$0.dateCreated ?? .now < $1.dateCreated ?? .now})
        }
        
        collection.reloadData()
        
        let title = filterAgeUp ? "Created  At  ↗" : "Created  At  ↘︎"
        
        createdAtFilterBtn.setTitle(title, for: .normal)
        filterAgeUp.toggle()
    }
    
    @IBAction func editFilterPrsd(_ sender: Any) {
        openCloseFilterBtns()
//        pageVM.filterMostRecent(orderUp: filterRecentUp)
//        corePages.removeAll()
        if filterRecentUp {
            corePages = corePages.sorted(by: {$0.dateEdited ?? .now > $1.dateEdited ?? .now})
        } else {
            corePages = corePages.sorted(by: {$0.dateEdited ?? .now < $1.dateEdited ?? .now})
        }
 
        collection.reloadData()
        
        let title = filterRecentUp ? "Recently Edited ↗" : "Recently Edited ↘︎"
        editedAtFilterBtn.setTitle(title, for: .normal)
        filterRecentUp.toggle()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
//        self.pages = self.pageVM.pageData.filter({$0.notes.contains(textField.text ?? "")})
        self.corePages = self.corePagesPreFilter.filter({$0.notes?.contains(textField.text ?? "") ?? false})
        collection.reloadData()
        if textField.text == "" {
            self.corePages = corePagesPreFilter
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
        let angle = newBookBtn.isHidden ? 0 : -(CGFloat.pi/4)
        UIView.animate(withDuration: 0.35) {
            self.menuBtnImage.transform = CGAffineTransform(rotationAngle: angle)
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
            vc.cBook = coreBook
            vc.cPageIndex = cPageIndex
        }
        
        if let vc = segue.destination as? DrawTypeViewController {
            vc.page = selectedPage
            vc.cBook = coreBook
            vc.cPageIndex = cPageIndex
            vc.cPage = corePage
        }
        
    }
    
    func showAlert(type: PageType, completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: "Enter Title", message: "", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Title"
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
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
            return .portrait
        } else {
            return .portrait
        }
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePageCell", for: indexPath) as! PageCollectionViewCell
        
        switch rowType[indexPath.row] {
        case .book(let book):
            cell.unSetupView()
            cell.htmlView.html = "<h3> \(book.title ?? "") </h3>"
        case .page(let page):
            if page.pageType == "draw" || page.pageType == "drawType"  {
                cell.bkGdImage.image = UIImage(data: page.drawing ?? .init())
                cell.setupView()
            } else if page.pageType == "type" {
                cell.unSetupView()
                cell.htmlView.html = page.notes ?? ""
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch rowType[indexPath.row] {
        case .book(let book):
            let index = DataManager.shared.coreBooks().firstIndex(where: {$0 == book})
            if index == nil {
                
            } else {
                bookIndex.append(index ?? 0)
                self.ressetView()
            }
        case .page(let page):
            selectedPage = Page(cPage: page)
            corePage = page 
            if page.pageType == "type" {
                self.performSegue(withIdentifier: "showTypeFromHome", sender: self)
            } else if page.pageType == "draw" || page.pageType == "drawType" {
                self.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) {[weak self] (_) in
                self?.cPageIndex = index
                switch self?.rowType[index] {
                case .book(let book):
                    let index = DataManager.shared.coreBooks().firstIndex(where: {$0 == book})
                    self?.bookIndex.append(index ?? 0)
                    self?.ressetView()
                case .page(let page):
                    self?.selectedPage = Page(cPage: page)
                    self?.corePage = page
                    
                    if page.pageType == "type" {
                        self?.performSegue(withIdentifier: "showTypeFromHome", sender: self)
                    } else if page.pageType == "draw" || page.pageType == "drawType" {
                        self?.performSegue(withIdentifier: "showDrawFromHome", sender: self)
                    }
                case .none:
                    ()
                }
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { [weak self] (_) in
                switch self?.rowType[index] {
                case .page(let page):
                    DataManager.shared.deletePage(corePage: page )
                    self?.rowType.remove(at: index)
//                    self?.corePagesPreFilter.remove(at: index)
                case .book(let book):
                    DataManager.shared.deleteBook(coreBook: book )
                    self?.rowType.remove(at: index)
//                    self?.corePagesPreFilter.remove(at: index)
                case .none: ()
                }
                self?.collection.reloadData()
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
            
        }
        return context
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRowTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "listOfBooks", for: indexPath)
        
        switch allRowTypes[indexPath.row] {
        case .page(let page):
            if page.pageType == "type" {
                cell.textLabel?.text = page.notes ?? ""
            } else {
                cell.textLabel?.text = page.title
            }
        case .book(let book):
            cell.textLabel?.text = book.title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch allRowTypes[indexPath.row] {
        case .page(let page):
            self.selectedPage = Page(cPage: page)
            self.corePage = page
            self.coreBook = page.book ?? .init()
            
            if page.pageType == "type" {
                self.performSegue(withIdentifier: "showTypeFromHome", sender: self)
            } else if page.pageType == "draw" || page.pageType == "drawType" {
                self.performSegue(withIdentifier: "showDrawFromHome", sender: self)
            }
            showSideBarMenu()
        case .book(let book):
            let index = DataManager.shared.coreBooks().firstIndex(where: {$0 == book})
            bookIndex.append(index ?? 0)
            ressetView()
            showSideBarMenu()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            allRowTypes = allRowTypesPreSearchState
            tableView.reloadData()
        } else {
            allRowTypes = allRowTypesPreSearchState.filter({$0.title.lowercased().contains(searchText.lowercased())})
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //
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

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
