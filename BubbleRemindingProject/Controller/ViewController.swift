//
//  ViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 02/12/2018.
//  Copyright © 2018 Aleksandra Konopka. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class ViewController: UIViewController, ReceiveDeletedPlace, CLLocationManagerDelegate,ReceiveNewFavouritePlace,SendBackToDoListArrayFromFavVCToVC {
    let defaults = UserDefaults.standard
    let center = UNUserNotificationCenter.current()
    @IBOutlet weak var whereAmILabel: UILabel!
    @IBOutlet weak var whereAmILabeltwo: UILabel!
    @IBOutlet var goToBubblesButton: UIButton!
    let dataFilePathToDoItems = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItems.plist")
    var arrayToDoItem: [ToDoItem]?
    var tabFav: [FavouritePlace]?
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FavouritePlaces.plist")
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let color = defaults.colorForKey(key: "LowColor")
        {
            lowColor = color
        }
        if let color = defaults.colorForKey(key: "MediumColor")
        {
            mediumColor = color
        }
        if let color = defaults.colorForKey(key: "HighColor")
        {
            highColor = color
        }
//        print("HIGH \(highColor)")
//        print("LOW \(lowColor)")
//        print("MEDIUM \(mediumColor)")
       // cleanToDoItems()
        super.viewWillLayoutSubviews()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            print(error)
        }
        locationManager.startUpdatingLocation()
        print(locationManager.monitoredRegions)
//        for region in locationManager.monitoredRegions {
//            locationManager.stopMonitoring(for: region)
//        }
     //  cleanToDoItems()
        loadData() // * wczytuje dane i zaczynam dla nich obserwowac na początku działania aplikacji
        loadDataToDoItem() // wczytuje arrayToDoItem
        //print("ARRAY TO DO ITEM: \(arrayToDoItem)")
        //print("MyTAbFav \(tabFav)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //print("Dla nich monitorujemy: \(locationManager.monitoredRegions)")
        var regionyMonitorowane: String = "Regiony monitorowane: "
        for region in locationManager.monitoredRegions
        {
            regionyMonitorowane += " " + region.identifier
        }
        whereAmILabeltwo.text = regionyMonitorowane
        goToBubblesButton.layer.cornerRadius = 0.5 * goToBubblesButton.frame.width
        //print("goToBubblesButton.frame.width \(goToBubblesButton.frame.width)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlace"
        {
            let secondVC = segue.destination as! AddViewController
            secondVC.delegate = self
            secondVC.array = tabFav
        }
        if segue.identifier == "goToFavourites"
        {
            let favouritesVC = segue.destination as! FavouritesViewController
            if tabFav != nil {
            favouritesVC.arrayOfFavouritePlaces = tabFav!
            }
            favouritesVC.arrayToDoItem = arrayToDoItem
            favouritesVC.delegate = self
            favouritesVC.delegateSendBackPlacesAndItems = self
            favouritesVC.delegateSendBack = self

        }
        if segue.identifier == "goToBubbles"
        {
            let bubbleVC = segue.destination as! BubblesViewController
            bubbleVC.delegate = self
            if ( arrayToDoItem != nil)
            {
                bubbleVC.allItems = arrayToDoItem!
            }
            else
            {
               bubbleVC.allItems = []
            }
            if ( tabFav != nil )
            {
                bubbleVC.favouritePlaces = tabFav!
            }
            else
            {
                bubbleVC.favouritePlaces = []
            }
            bubbleVC.fromMainVc = true
        }
    }
    func placeReceived(place: FavouritePlace){
        if (self.tabFav?.append(place)) == nil {
            self.tabFav = [place]
        }
        startMonitoring(places: [place])
        //print("Tab Fav \(self.tabFav!)")
        self.saveToPlist()
    }
    func deletedPlaceReceived(deletedPlace: FavouritePlace) {
        self.tabFav?.removeAll(where: { (place) in
            if(place.name == deletedPlace.name)
            {
            stopMonitoring(place:place)
            }
            return place.name == deletedPlace.name
        })
        self.saveToPlist()
        //print("Dla nich monitorujemy po usunieciu: \(locationManager.monitoredRegions)")
        
    }
    func arrayReceived(array: [FavouritePlace]) {
        tabFav = array
       // print("Array received \(array) ")
    }
    func loadData()
    {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                tabFav = try decoder.decode([FavouritePlace].self, from: data)
                if tabFav != nil && tabFav!.count > 0
                {
                   // print("MY TAB FAV: \(tabFav)")
                startMonitoring(places:tabFav!)
                }
            } catch{
                print("Error decoding item array: \(error)")
            }
        }
    }
        func loadDataToDoItem()
        {
            if let data = try? Data(contentsOf: dataFilePathToDoItems!) {
                let decoder = PropertyListDecoder()
                do{
                    arrayToDoItem = try decoder.decode([ToDoItem].self, from: data)
                } catch{
                    print("Oh no, Error decoding item array: \(error)")
                }
            }
        }
    func startMonitoring(places: [FavouritePlace])
   {
        for place in places
        {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:place.lat,longitude:place.long), radius: 1000, identifier: place.name)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    func stopMonitoring(place: FavouritePlace)
    {
        for region in self.locationManager.monitoredRegions {
            if region.identifier == place.name {
            self.locationManager.stopMonitoring(for: region)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if tabFav == nil
        {
            tabFav = []
        }
        whereAmILabel.text = "You entered \(region.identifier)"
        let title = "You entered \(region.identifier)"
        let body = "Have you got things to do here?"
        createNotification(title: title, body: body)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if tabFav == nil
        {
            tabFav = []
        }

        whereAmILabel.text = "You left \(region.identifier)"
        let title = "You left \(region.identifier)"
        let body = "Have you had things to do here?"
        createNotification(title: title, body: body)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        whereAmILabel.text = "Error: \(error) Error for region: \(region!.identifier))"
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        whereAmILabel.text = "I cannot use your location!"
    }
    func saveToPlist()
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.tabFav)
            try data.write(to:self.dataFilePath!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
    
    func createNotification(title:String,body:String)
    {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let date = Date().addingTimeInterval(5)
        let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        self.center.add(request) { (error) in
            print(error)
        }
    }
    func toDoListArrayReceivedFromFavVC(data: [ToDoItem]) {
        arrayToDoItem = data
    }
    func cleanToDoItems()
    {
        let encoder = PropertyListEncoder()
        var cleanArray : [ToDoItem]
        cleanArray = []
        do {
            let data = try encoder.encode(cleanArray)
            try data.write(to:self.dataFilePathToDoItems!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
    
    @IBAction func goToBubblesPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToBubbles", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
         performSegue(withIdentifier: "goToSettings", sender: self)
    }
}

extension ViewController : SendBackMyListOfItemsFromBubblesToView
{
    func toDoListArrayReceivedFromBubbles(listOfItems: [ToDoItem]) {
        arrayToDoItem = listOfItems
    }
}

extension ViewController : SendBackPlacesAndItems
{
    func itemsAndPlacesUpdate(items: [ToDoItem], places: [FavouritePlace]) {
        arrayToDoItem = items
        tabFav = places
        //od nowa monitoruje zeby sie updatowala zmiana nazwy
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        if tabFav != nil && tabFav!.count > 0
        {
            startMonitoring(places:tabFav!)
        }
        var regionyMonitorowane: String = "Regiony monitorowane: "
        for region in locationManager.monitoredRegions
        {
            regionyMonitorowane += " " + region.identifier
        }
        whereAmILabeltwo.text = regionyMonitorowane
    }
}

