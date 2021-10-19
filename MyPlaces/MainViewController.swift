//
//  MainViewControllerTableViewController.swift
//  MyPlaces
//
//  Created by Roman Korobskoy on 19.10.2021.
//

import UIKit

class MainViewController: UITableViewController {
    
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
        
        //cell.textLabel?.text = restaurantNames[indexPath.row] //Deprecated iOS 13+
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(named: restaurantNames[indexPath.row])
        content.text = restaurantNames[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
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
