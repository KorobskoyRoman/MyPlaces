//
//  MainViewControllerTableViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 19.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let searchController = UISearchController(searchResultsController: nil) //объявляем контроллер для поиска
    private var places: Results<Place>! //обновляемые данные из базы данных
    private var filteredPlaces: Results<Place>! //массив результатов поиска
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool { //свойство проверки поиска на пустое значение
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty //проверяем активность поиска и заполненность
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
//    let resizeImage = UIView.ContentMode.scaleToFill
//    let restaurantNames = ["Краснодарский парень", "Fарш", "BQ125"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
//        let leftBarButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
//        leftBarButton.setImage(UIImage.init(named:"sortDown"), for: .normal)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarButton)
        
        //настроим контроллер поиска
        searchController.searchResultsUpdater = self //делаем наш класс получателем информации поиска
        searchController.obscuresBackgroundDuringPresentation = false //включаем взаимодествие с контроллером
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController //интегрируем строку в навигейшн бар
        definesPresentationContext = true //при переходе на другой экран поиск убираем
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count //отражаем кол-во отфильтрованных элементов
        }
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell //присваем значения ячейке из класса CustomTableViewCell
        
        var place = Place()

        if isFiltering { //если значение true - отображаем новый массив. иначе - старый
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        //присваиваем значения лейблов ячейкe
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //ширина ячейки
        cell.imageOfPlace.clipsToBounds = true
        cell.imageOfPlace.contentMode = .scaleAspectFill //ровняем картинку

        return cell
    }

    //MARK: Table view delegate
//deprecated iOS 13+
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let place = places[indexPath.row]
//        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { _, _ in
//            StorageManager.deleteObject(place)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        return [deleteAction]
//    }
//                          ^
// удалить при рефакторинге |
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //убираем выделение ячейки
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction]) //взаимствовано с хабра
        return swipeAction
    }


    //передаем объект по индксу строки и открываем его
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering { //отражаем отфильтрованный массив или нет в зависимости от фильтра
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    //создаем сигвей для сохранения значений из NewPlaceViewController в наш основной
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace() //вызываем ранее созданный метод для сохранения контента
        tableView.reloadData() //обновляем вью
    }
    
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
//        setUpMenuButton()
        
        ascendingSorting.toggle()
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "sortDown")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "sortUp")
        }
        
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
//    func setUpMenuButton(){
//        let menuBtn = UIButton(type: .custom)
//        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
//        menuBtn.setImage(UIImage(named:"menuIcon"), for: .normal)
//        //menuBtn.addTarget(self, action: #selector(MainViewController.onMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
//
//        let menuBarItem = UIBarButtonItem(customView: menuBtn)
//        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
//        currWidth?.isActive = true
//        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
//        currHeight?.isActive = true
//        self.navigationItem.leftBarButtonItem = menuBarItem
//    }
    
//    func setRating() {
//        for _ in 0..<5{
//            let bundle = Bundle(for: type(of: self))
//            let filledStar = UIImage(named: "filledStar",
//                                     in: bundle,
//                                     compatibleWith: self.traitCollection)
//            let emptyStar = UIImage(named: "emptyStar",
//                                    in: bundle,
//                                    compatibleWith: self.traitCollection)
//            let image = UIImageView()
//
//        }
//    }
}

extension MainViewController: UISearchResultsUpdating { //подписываемся под протокол для поиска в текущем контроллере
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchTet(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchTet(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText) //настраиваем запрос поиска через Realm по полям name или location без привязки по регистру символов
        tableView.reloadData()
    }
}
