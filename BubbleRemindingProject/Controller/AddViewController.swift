//
//  AddViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 02/12/2018.
//  Copyright © 2018 Aleksandra Konopka. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


protocol ReceiveNewFavouritePlace
{
    func placeReceived(place: FavouritePlace)
}

class AddViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FavouritePlaces.plist")
    var delegate : ReceiveNewFavouritePlace?
    @IBOutlet weak var zoomButton: UIButton!
    var zoom = true
    var favLongitude:Double?
    var favLatitude:Double?
    @IBOutlet weak var myMap: MKMapView!
    var array = [FavouritePlace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myMap.delegate = self
        self.myMap.showsUserLocation = true
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if zoom == true {
            zoomOnMe()
        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func zoomButtonClicked(_ sender: Any) {
        if zoom == true
        {
            zoom = false
            zoomButton.setTitle("Follow me!",for: .normal)
        }else{
            zoom = true
            zoomButton.setTitle("Don't follow me!",for: .normal)
            zoomOnMe()
        }
        
    }
    
    func zoomOnMe()
    {
        let region = MKCoordinateRegion(center: myMap.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        myMap.setRegion(region,animated:true)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
      
        if array.count >= 20
        {
          upsAlert(title:"UPS",message:"You can't have more than 20 favourite places!")
        }
        else
        {
        self.favLatitude = nil
        self.favLongitude = nil
        cleanMap()
        zoom = false
        let alert = UIAlertController(title: "Find the place", message: "Enter the address of the location", preferredStyle: .alert )
        alert.addTextField{textfield in}
        
        let ok = UIAlertAction(title: "OK", style: .default){ action in
            if let textfield = alert.textFields?.first{
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(textfield.text!){ (placemarks,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    guard let placemarks = placemarks,
                        let placemark = placemarks.first else {
                            return
                    }
                    let coordinate = placemark.location?.coordinate
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate!
                    annotation.title = textfield.text!
                    self.myMap.addAnnotation(annotation)
                    
                    self.favLatitude = coordinate!.latitude
                    self.favLongitude = coordinate!.longitude
                    
                    let regionFav = MKCoordinateRegion(center: coordinate!, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
                    self.myMap.setRegion(regionFav,animated:true)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel){
            action in
            }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert,animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let favLat = favLatitude{
            let favLong = favLongitude!
            let alert = UIAlertController(title: "Name your favourite Location", message: nil, preferredStyle: .alert )
            alert.addTextField{textfield in}
            
            let save = UIAlertAction(title: "Save", style: .default){ action in
                if let textfield = alert.textFields?.first{
                    var found = false
                    for element in self.array
                    {
                        if (element.name == textfield.text!){
                            found = true
                        }
                    }
                    if (found == true){
                        self.upsAlert(title: "UPS!", message: "You already have a place with this name!")
                    }
                    else {
                        var coordinatesAlreadyFound = false;
                        for element in self.array
                        {
                            if (element.long == favLong && element.lat == favLat){
                                coordinatesAlreadyFound = true
                            }
                        }
                        if(coordinatesAlreadyFound == true)
                        {
                            self.upsAlert(title: "UPS!", message: "You already have a place with this coordinates!")
                        }
                        else {
                            if (alert.textFields?.first!.text! != "Noname" && alert.textFields!.first!.text!.count > 1  )
                            {
                                let favName = textfield.text!
                                let favPlace = FavouritePlace(name: favName, long: favLong, lat: favLat)
                                //*Zamiast dodac do tablicy wysle sam element i dodam go do tablicy w viewcontrollerze głównym
                                self.array.append(favPlace)
                                self.delegate?.placeReceived(place: favPlace)
                                self.upsAlert(title: "Oh yea", message: "New item has been successfully added!")
                            }
                            else
                            {
                                self.upsAlert(title: "UPS!", message: "Wrong name!")
                            }
                        }
                    }
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel){
                action in
            }
            alert.addAction(save)
            alert.addAction(cancel)
            self.present(alert,animated: true, completion: nil)
            
        }
        else {
            upsAlert(title: "Oh no!", message: "You need to add a place first.")
        }
    }
    
    @IBAction func showButtonPressed(_ sender: UIButton) {
        cleanMap()
        if array.count>0 {
        for element in array
        {
            addPointOfInterest(element: element)
        }
            let coordinate = CLLocationCoordinate2D(latitude: array[array.count-1].lat, longitude: array[array.count-1].long)
            let regionFav = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
            self.myMap.setRegion(regionFav,animated:true)
        }
        else
        {
            upsAlert(title: "Oh no!", message:"You have no favourite places!" )
        }
    }
    
    func upsAlert(title:String,message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        let ok = UIAlertAction(title: "OK", style: .cancel){
            action in
        }
        alert.addAction(ok)
        self.present(alert,animated: true, completion: nil)
    }
    
    private func addPointOfInterest(element:FavouritePlace)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:element.lat,longitude:element.long)
        annotation.title = element.name
        self.myMap.addAnnotation(annotation)
        self.myMap.addOverlay(MKCircle(center: annotation.coordinate, radius: 1000))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(circle:overlay as! MKCircle)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purple
            circleRenderer.fillColor = UIColor.green
            circleRenderer.alpha = 0.4
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    func cleanMap()
    {
        myMap.removeAnnotations(myMap.annotations)
        myMap.removeOverlays(myMap.overlays)
    }
}
