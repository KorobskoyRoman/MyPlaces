//
//  MainViewControllerTableViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 19.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
//    let resizeImage = UIView.ContentMode.scaleToFill
//    let restaurantNames = ["Краснодарский парень", "Fарш", "BQ125"]
    
    var places: Results<Place>! //обновляемые данные из базы данных

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell //присваем значения ячейке из класса CustomTableViewCell

        let place = places[indexPath.row] //делаем код более читабельным ниже

        //присваиваем значения лейблов ячейки
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction]) //взаимствовано с хабра
        return swipeAction
    }
    
    //создаем сигвей для сохранения значений из NewPlaceViewController в наш основной
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.saveNewPlace() //вызываем ранее созданный метод для сохранения контента
        tableView.reloadData() //обновляем вью
    }
    
}

