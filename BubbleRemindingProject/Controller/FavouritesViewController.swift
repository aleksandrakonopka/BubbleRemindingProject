//
//  FavouritesViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 02/12/2018.
//  Copyright © 2018 Aleksandra Konopka. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol ReceiveDeletedPlace{
    func deletedPlaceReceived(deletedPlace:FavouritePlace)
}
protocol SendBackToDoListArrayFromFavVCToVC
{
    func toDoListArrayReceivedFromFavVC(data:[ToDoItem])
}
protocol SendBackPlacesAndItems
{
    func itemsAndPlacesUpdate(items:[ToDoItem],places:[FavouritePlace])
}

class FavouritesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource/*, SendBackToDoListArray*/{
    var placeId = "noId"
    let dataFilePathToDoItems = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItems.plist")
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FavouritePlaces.plist")
    var arrayOfFavouritePlaces = [FavouritePlace]()
    var array = [FavouritePlace]()
    var deletedPlaces = [FavouritePlace]()
    var arrayToDoItem = [ToDoItem]()
    var delegate : ReceiveDeletedPlace?
    var delegateSendBack : SendBackToDoListArrayFromFavVCToVC?
    var delegateSendBackPlacesAndItems : SendBackPlacesAndItems?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = array[indexPath.row].name
        return cell
    }
    
    @IBOutlet weak var myTable: UITableView!
    override func viewDidLoad() {
        array = arrayOfFavouritePlaces
        array.append(FavouritePlace(name: "Noname", long: 181.0, lat: 181.0))
//       print("ARRAY TO DO ITEMS IN FAVOURITES \(arrayToDoItem!)")
        print(dataFilePathToDoItems!)
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("ARRAY TO DO ITEMM favvc \(arrayToDoItem)")
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegateSendBack?.toDoListArrayReceivedFromFavVC(data: arrayToDoItem)
        delegateSendBackPlacesAndItems?.itemsAndPlacesUpdate(items: arrayToDoItem, places: arrayOfFavouritePlaces)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            if self.array[indexPath.row].name == "Noname" {
                let alertNonameE = UIAlertController(title: "Im sorry", message: "You cannot edit \"Noname\" - it is not a place!", preferredStyle: .alert )
                let yesButtonNonameE = UIAlertAction(title: "Ok", style: .default){ action in
                }
                alertNonameE.addAction(yesButtonNonameE)
                self.present(alertNonameE,animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Enter Place Name", message: "Change this place name: \"\(self.array[indexPath.row].name)\"", preferredStyle: .alert )
                alert.addTextField{textfield in}
                alert.textFields![0].text = self.array[indexPath.row].name
                print(self.array[indexPath.row].name)
                let yesButton = UIAlertAction(title: "Save", style: .default){ action in
                    print("Save")
                
                    if ( alert.textFields![0].text!.count > 1 && alert.textFields![0].text != "Noname" )
                    {
                        var index = 0
                        for toDoElement in self.arrayToDoItem
                        {
                            if toDoElement.placeName == self.array[indexPath.row].name
                           {
                             self.arrayToDoItem[index].placeName = alert.textFields![0].text!
                            }
                            index = index + 1
                        }
                        index = 0
                        for placeElement in self.array
                        {
                            if placeElement.name == self.array[indexPath.row].name
                            {
                                self.arrayOfFavouritePlaces[index].name = alert.textFields![0].text!
                                self.array[index].name = alert.textFields![0].text!
                            }
                            index = index + 1
                        }
                        self.myTable.reloadData()
                        self.saveToChosenPlist(filePath: self.dataFilePath!, table: self.arrayOfFavouritePlaces)
                        self.saveToChosenPlist(filePath: self.dataFilePathToDoItems!, table: self.arrayToDoItem)
 
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Ups", message: "Wrong name!", preferredStyle: .alert )
                        let okButton = UIAlertAction(title: "Ok", style: .default){ action in
                        }
                        alert.addAction(okButton)
                        self.present(alert,animated: true, completion: nil)
                    }
                }
                
                let noButton = UIAlertAction(title: "Cancel", style: .cancel){
                    action in
                    print("Cancel")
                }
                alert.addAction(yesButton)
                alert.addAction(noButton)
                self.present(alert,animated: true, completion: nil)
            }
        }
        editButton.backgroundColor = UIColor.blue
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if (self.array[indexPath.row].name != "Noname") {
                let alert = UIAlertController(title: "Are you sure?", message: "Would you like to delete this favourite place - '\(self.array[indexPath.row].name)' with all related ToDoItems?", preferredStyle: .alert )
                
                let yesButton = UIAlertAction(title: "Yes", style: .default){ action in
                    self.myTable.beginUpdates()
                    self.myTable.deleteRows(at: [indexPath], with: .left)
                    var number = 0
                    for element in self.arrayToDoItem
                    {
                        if(element.placeName == self.array[indexPath.row].name)
                        {
                            self.arrayToDoItem.remove(at: number)
                        }
                        else
                        {
                            number = number + 1
                        }
                    }
                    self.delegate?.deletedPlaceReceived(deletedPlace:self.array[indexPath.row])
                    self.array.remove(at: indexPath.row)
                    self.arrayOfFavouritePlaces.remove(at: indexPath.row)
                    self.myTable.endUpdates()
                    self.saveToChosenPlist(filePath: self.dataFilePathToDoItems!, table: self.arrayToDoItem)
                }
                
                let noButton = UIAlertAction(title: "No", style: .cancel){
                    action in
                }
                
                alert.addAction(yesButton)
                alert.addAction(noButton)
                self.present(alert,animated: true, completion: nil)
            }
            if (self.array[indexPath.row].name == "Noname") {
                let alertNonameE = UIAlertController(title: "Im sorry", message: "You cannot delete \"Noname\" - it is not a place!", preferredStyle: .alert )
                let yesButtonNonameE = UIAlertAction(title: "Ok", style: .default){ action in
                }
                alertNonameE.addAction(yesButtonNonameE)
                self.present(alertNonameE,animated: true, completion: nil)
            }
            
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [editButton,deleteButton]
    }
    
    func saveToChosenPlist<T: Encodable>(filePath:URL, table: T)
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(table)
            try data.write(to:filePath)
        }
        catch {
            print("Error encoding item array \(error)")
        }
        print("Weszlo1")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("INDEX PATH: \(indexPath.row), ELEMENT ID: \(array![indexPath.row].name)")
        placeId = array[indexPath.row].name
        performSegue(withIdentifier: "goToChosenBubbles", sender: self)
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChosenBubbles"
        {
            let bubbleVC = segue.destination as! BubblesViewController
            bubbleVC.bubblesFromOnePlace = true
            bubbleVC.secondDelegate = self
           
            let chosenItems = arrayToDoItem.filter(){
                if $0.placeName == placeId{
                    return true
                }else{
                    return false
                }
            }
            print("Items we send: \(arrayToDoItem)")
            print("Chosen items we send: \(chosenItems)")
            bubbleVC.allItems = arrayToDoItem
            bubbleVC.chosenPlaceItems = chosenItems
            
            
            if ( arrayOfFavouritePlaces.count > 0 )
            {
                bubbleVC.favouritePlaces = arrayOfFavouritePlaces
            }
            else
            {
                bubbleVC.favouritePlaces = []
            }
            bubbleVC.chosenPlace = placeId
        }
    }
   func toDoListArrayReceived(data: [ToDoItem]){
        arrayToDoItem = data
    }
}

extension FavouritesViewController : SendBackMyListOfItemsFromBubblesToTable
{
    func toDoListArrayReceivedFromBubblesToTable(listOfItems: [ToDoItem]) {
        arrayToDoItem = listOfItems
    }
    
}
