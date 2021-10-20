//
//  MainViewControllerTableViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 19.10.2021.
//

import UIKit

class MainViewController: UITableViewController {
    
//    let resizeImage = UIView.ContentMode.scaleToFill
    let restaurantNames = ["Краснодарский парень", "Fарш", "BQ125"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        cell.textLabel?.text = restaurantNames[indexPath.row] //Deprecated iOS 13+
//        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
//        cell.imageView?.layer.cornerRadius = 85 / 2
//        cell.imageView?.clipsToBounds = true
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(named: restaurantNames[indexPath.row])

        content.text = restaurantNames[indexPath.row]

        content.imageProperties.maximumSize.width = cell.frame.size.width - 5
        content.imageProperties.maximumSize.height = cell.frame.size.height - 5
        content.imageProperties.cornerRadius = cell.frame.size.height / 2

        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
