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
    var array: [FavouritePlace]?
    var deletedPlaces: [FavouritePlace]?
    //To Do Item
    var arrayToDoItem: [ToDoItem]?
    //var arrayToDoItems = [ToDoItem(placeName:"warszawa", item: "umyc kwiatki")]
    //var delegate : ReceiveModifiedArray?
    var delegate : ReceiveDeletedPlace?
    var delegateSendBack : SendBackToDoListArrayFromFavVCToVC?
    var delegateSendBackPlacesAndItems : SendBackPlacesAndItems?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  array == nil {
            return 0
        }
        else
        {
        return array!.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = array![indexPath.row].name
        return cell
    }
    
    @IBOutlet weak var myTable: UITableView!
    override func viewDidLoad() {
        array = arrayOfFavouritePlaces
        array!.append(FavouritePlace(name: "Noname", long: 181.0, lat: 181.0))
       // loadDataToDoItem()
//       print("ARRAY TO DO ITEMS IN FAVOURITES \(arrayToDoItem!)")
        print(dataFilePathToDoItems!)
        super.viewDidLoad()
        
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
//        if array != nil {
//        delegate?.arrayReceived(array: array!)
//        }
//        else
//        {
//          delegate?.arrayReceived(array: [])
//        }
        if arrayToDoItem == nil{
            arrayToDoItem=[]
        }
        delegateSendBack?.toDoListArrayReceivedFromFavVC(data: arrayToDoItem!)
        delegateSendBackPlacesAndItems?.itemsAndPlacesUpdate(items: arrayToDoItem!, places: arrayOfFavouritePlaces)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            if self.array![indexPath.row].name == "Noname" {
                let alertNonameE = UIAlertController(title: "Im sorry", message: "You cannot edit \"Noname\" - it is not a place!", preferredStyle: .alert )
                let yesButtonNonameE = UIAlertAction(title: "Ok", style: .default){ action in
                }
                alertNonameE.addAction(yesButtonNonameE)
                self.present(alertNonameE,animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Enter Place Name", message: "Change this place name: \"\(self.array![indexPath.row].name)\"", preferredStyle: .alert )
                alert.addTextField{textfield in}
                alert.textFields![0].text = self.array![indexPath.row].name
                print(self.array![indexPath.row].name)
                let yesButton = UIAlertAction(title: "Save", style: .default){ action in
                    print("Save")
                
                if ( alert.textFields![0].text!.count > 1 && alert.textFields![0].text != "Noname" )
                {
                    var index = 0
                    for toDoElement in self.arrayToDoItem!
                    {
                        if toDoElement.placeName == self.array![indexPath.row].name
                       {
                         self.arrayToDoItem![index].placeName = alert.textFields![0].text!
                        }
                        index = index + 1
                    }
                    index = 0
                    for placeElement in self.array!
                    {
                        if placeElement.name == self.array![indexPath.row].name
                        {
                            self.arrayOfFavouritePlaces[index].name = alert.textFields![0].text!
                            self.array![index].name = alert.textFields![0].text!
                        }
                        index = index + 1
                    }
                    self.myTable.reloadData()
                    self.saveToPlistAOFP()
                    self.saveToPlistToDoItem()
                    print(self.arrayToDoItem)
                    print(self.array)
                    print(self.arrayOfFavouritePlaces)
                    //posłać przez protokół do tyłu arrayItemów i arrayUlubionych miejsc
                    
                }
                else
                {
                    let alert = UIAlertController(title: "Ups", message: "Wrong name!", preferredStyle: .alert )
                    let okButton = UIAlertAction(title: "Ok", style: .default){ action in
                    }
                    alert.addAction(okButton)
                    self.present(alert,animated: true, completion: nil)
                }
//                    // NIE USUWAC
//                    self.myTable.beginUpdates()
//                    self.myTable.deleteRows(at: [indexPath], with: .left)
//                    var number = 0
//                    for element in self.arrayToDoItem!
//                    {
//                        if(element.placeName == self.array![indexPath.row].name)
//                        {
//                            self.arrayToDoItem?.remove(at: number)
//                        }
//                        else
//                        {
//                            number = number + 1
//                        }
//                    }
//                    self.delegate?.deletedPlaceReceived(deletedPlace:self.array![indexPath.row])
//                    self.array?.remove(at: indexPath.row)
//                    self.myTable.endUpdates()
//                    self.saveToPlistToDoItem()
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
            if (self.array![indexPath.row].name != "Noname") {
                let alert = UIAlertController(title: "Are you sure?", message: "Would you like to delete this favourite place - '\(self.array![indexPath.row].name)' with all related ToDoItems?", preferredStyle: .alert )
                let yesButton = UIAlertAction(title: "Yes", style: .default){ action in
                    print("Yes")
                    // NIE USUWAC
                    self.myTable.beginUpdates()
                    self.myTable.deleteRows(at: [indexPath], with: .left)
                    var number = 0
                    for element in self.arrayToDoItem!
                    {
                        if(element.placeName == self.array![indexPath.row].name)
                        {
                            self.arrayToDoItem?.remove(at: number)
                        }
                        else
                        {
                            number = number + 1
                        }
                    }
                    self.delegate?.deletedPlaceReceived(deletedPlace:self.array![indexPath.row])
                    self.array?.remove(at: indexPath.row)
                    self.arrayOfFavouritePlaces.remove(at: indexPath.row)
                    self.myTable.endUpdates()
                    self.saveToPlistToDoItem()
                }
                
                let noButton = UIAlertAction(title: "No", style: .cancel){
                    action in
                    print("No")
                }
                alert.addAction(yesButton)
                alert.addAction(noButton)
                self.present(alert,animated: true, completion: nil)
                
                //NIE USUWAC
                //            myTable.beginUpdates()
                //            myTable.deleteRows(at: [indexPath], with: .left)
                //            self.delegate?.deletedPlaceReceived(deletedPlace:array![indexPath.row])
                //            array?.remove(at: indexPath.row)
                //            myTable.endUpdates()
            }
            if (self.array![indexPath.row].name == "Noname") {
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
//        if (editingStyle == .delete && array![indexPath.row].name != "Noname") {
//            let alert = UIAlertController(title: "Are you sure?", message: "Would you like to delete this favourite place - '\(array![indexPath.row].name)' with all related ToDoItems?", preferredStyle: .alert )
//            let yesButton = UIAlertAction(title: "Yes", style: .default){ action in
//                print("Yes")
//               // NIE USUWAC
//                self.myTable.beginUpdates()
//                self.myTable.deleteRows(at: [indexPath], with: .left)
//                var number = 0
//                for element in self.arrayToDoItem!
//                {
//                    if(element.placeName == self.array![indexPath.row].name)
//                    {
//                        self.arrayToDoItem?.remove(at: number)
//                    }
//                    else
//                    {
//                        number = number + 1
//                    }
//                }
//                self.delegate?.deletedPlaceReceived(deletedPlace:self.array![indexPath.row])
//                self.array?.remove(at: indexPath.row)
//                self.myTable.endUpdates()
//                self.saveToPlistToDoItem()
//            }
//
//            let noButton = UIAlertAction(title: "No", style: .cancel){
//                action in
//                print("No")
//            }
//            alert.addAction(yesButton)
//            alert.addAction(noButton)
//            self.present(alert,animated: true, completion: nil)
//
//            //NIE USUWAC
////            myTable.beginUpdates()
////            myTable.deleteRows(at: [indexPath], with: .left)
////            self.delegate?.deletedPlaceReceived(deletedPlace:array![indexPath.row])
////            array?.remove(at: indexPath.row)
////            myTable.endUpdates()
//        }
//         if (editingStyle == .delete && array![indexPath.row].name == "Noname") {
//            let alertNoname = UIAlertController(title: "Im sorry", message: "You cannot delete \"Noname\" - it is not a place!", preferredStyle: .alert )
//            let yesButtonNoname = UIAlertAction(title: "Ok", style: .default){ action in
//            }
//            alertNoname.addAction(yesButtonNoname)
//            self.present(alertNoname,animated: true, completion: nil)
//            }
        
    }
    func saveToPlist()
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.array)
            try data.write(to:self.dataFilePath!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
    func saveToPlistAOFP()
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.arrayOfFavouritePlaces)
            try data.write(to:self.dataFilePath!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("INDEX PATH: \(indexPath.row), ELEMENT ID: \(array![indexPath.row].name)")
        placeId = array![indexPath.row].name
        performSegue(withIdentifier: "goToChosenBubbles", sender: self)
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToToDoList"
//        {
//            let toDoVC = segue.destination as! ToDoTableViewController
//            toDoVC.placeId = placeId
//            toDoVC.array = arrayToDoItem
//         //   print("ARRAYTODOITEMS FAV \(arrayToDoItem!)")
//            toDoVC.delegate = self
//        }
        if segue.identifier == "goToChosenBubbles"
        {
            let bubbleVC = segue.destination as! BubblesViewController
            bubbleVC.bubblesFromOnePlace = true
            bubbleVC.secondDelegate = self
            if ( arrayToDoItem != nil)
            {
                            let chosenItems = arrayToDoItem?.filter(){
                                if $0.placeName == placeId{
                                    return true
                                }else{
                                    return false
                                }
                            }
                bubbleVC.allItems = arrayToDoItem!
                if chosenItems != nil
                {
                bubbleVC.chosenPlaceItems = chosenItems!
                }
                else
                {
                    bubbleVC.chosenPlaceItems = []
                    bubbleVC.allItems = []
                }
            }
            else
            {
                bubbleVC.chosenPlaceItems = []
            }
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
        print("Zadziałało!")
    }
    func saveToPlistToDoItem()
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.arrayToDoItem)
            try data.write(to:self.dataFilePathToDoItems!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
//    func loadDataToDoItem()
//    {
//        if let data = try? Data(contentsOf: dataFilePathToDoItems!) {
//            let decoder = PropertyListDecoder()
//            do{
//                arrayToDoItem = try decoder.decode([ToDoItem].self, from: data)
//            } catch{
//                print("Error decoding item array: \(error)")
//            }
//        }
//    }


}
extension FavouritesViewController : SendBackMyListOfItemsFromBubblesToTable
{
    func toDoListArrayReceivedFromBubblesToTable(listOfItems: [ToDoItem]) {
        arrayToDoItem = listOfItems
    }
    
}
