//
//  ViewController.swift
//  Weather
//
//  Created by Yu Wang on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        deletedObjectsFromRealmDb()
        return arrCurrentWeather.count // You will replace this with arrCurrentWeather.count
//        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currWeather = arrCurrentWeather[indexPath.row]
//
        let displayContent = String("\(currWeather.cityInfoName), \(currWeather.temp)ºF")
        print("content -> \(displayContent)")
        cell.textLabel?.text = displayContent // replace this with values from arrCurrentWeather array
//        cell.textLabel?.text = arr[indexPath.row]
        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
//        deletedObjectsFromRealmDb()
        do {
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            print("read realm, cities -> \(cities)")
            self.arrCityInfo.removeAll()
            getAllCurrentWeather(Array(cities)).done { CurrentWeather in
                self.tblView.reloadData()
            }
            .catch{ error in
                print(error)
            }
        } catch {
            print("Error in reading Database \(error)")
        }

    }

    func getCurWeatherSearchURL(_ locationKey: String) -> String {
        return "\(currentConditionURL)\(locationKey)?apikey=\(apiKey)"
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ..< cities.count {
                promises.append( getCurrentWeather(cities[i]))
            }
            
            return when(fulfilled: promises)
             
        }
    
    
    func getCurrentWeather(_ city : CityInfo) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = getCurWeatherSearchURL(city.key)// build URL for current weather here
                
                AF.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let json = JSON(response.data)
//                    print("current info: \(json)")
                  
                    for item in json.arrayValue {
                        let currentWeather = CurrentWeather()
                        
                        currentWeather.cityKey = city.key
                        currentWeather.cityInfoName = "\(city.localizedName), \(city.administrativeID), \(city.countryLocalizedName)"
                        currentWeather.weatherText = item["WeatherText"].stringValue
                        currentWeather.epochTime = item["EpochTime"].intValue
                        currentWeather.isDayTime = item["IsDayTime"].boolValue
                        currentWeather.temp = item["Temperature"]["Imperial"]["Value"].intValue
                        self.arrCurrentWeather.append(currentWeather)
                        seal.fulfill(currentWeather)
                    }
                    
                    
                }
            }
    }
    
    func deletedObjectsFromRealmDb(){
           let realm = try! Realm()
           try! realm.write {
               realm.deleteAll()
           }
    }

}

