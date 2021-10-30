//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Yu Wang on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
       
    var arrCityInfo : [CityInfo] = [CityInfo]()

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let curCity = arrCityInfo[indexPath.row]
        let cityDisplayContent = " \(curCity.localizedName), \(curCity.administrativeID), \(curCity.countryLocalizedName)"
        cell.textLabel?.text = cityDisplayContent // You will change this to getr values from arrCityinfo and assign text
        
        return cell
    }
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        // Network call from there
        let url = getSearchURL(searchText)
        
    
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            
            
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrCityInfo
            // Reload table with the values
            let json = JSON(response.data!)
            // clear before info to save new result
            self.arrCityInfo.removeAll()
            
            for city in json.arrayValue {
                let newCity = CityInfo()
                
                newCity.key = city["key"].stringValue
                newCity.type = city["Type"].stringValue
                newCity.localizedName = city["LocalizedName"].stringValue
                newCity.administrativeID = city["AdministrativeArea"]["ID"].stringValue
                newCity.countryLocalizedName = city["Country"]["LocalizedName"].stringValue
                
                self.arrCityInfo.append(newCity)
            }
            // clear and refresh
//            self.arrCityInfo.removeAll()
            self.tblView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        let city = arrCityInfo[indexPath.row]

        do {
            let realm = try! Realm()
            try realm.write{
                realm.add(city)
            }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "Home")
        
            self.navigationController?.pushViewController(destination, animated: true)
        } catch {
            print("Error in initializing realm")
        }
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // You will get the Index of the city info from here and then add it into the realm Database
//        // Once the city is added in the realm DB pop the navigation view controller
//        let selectCity = arrCityInfo[indexPath.row]
//        do {
//            let realm = try! Realm()
//            try realm.write{
//                realm.add(selectCity)
//            }
//            [self.navigationController?.popViewController(animated: true)]
//        } catch {
//            print("add data failed!")
//        }
//    }

    func deletedObjectsFromRealmDb(){
           let realm = try! Realm()
           try! realm.write {
               realm.deleteAll()
           }
    }
}
