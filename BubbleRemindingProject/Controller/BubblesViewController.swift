//
//  BubblesViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 14/02/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import UIKit

protocol SendBackMyListOfItemsFromBubblesToView
{
    func toDoListArrayReceivedFromBubbles(listOfItems:[ToDoItem])
}
protocol SendBackMyListOfItemsFromBubblesToTable
{
    func toDoListArrayReceivedFromBubblesToTable(listOfItems:[ToDoItem])
}

class BubblesViewController: UIViewController {
    @IBOutlet var placeLabel: UILabel!
    var fromMainVc = false
    var addBubbleToDifferentPlace = false
    var addedBubblePlace = ""
    var chosenPlace = ""
    var bubblesFromOnePlace = false
    var isEditingBubble = false
    @IBOutlet var editDeleteView: UIView!
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItems.plist")
    
    @IBOutlet var deleteBubble: UIButton!
    @IBOutlet var editBubble: UIButton!
    
    @IBOutlet var selectedNameLabel: UILabel!
    @IBOutlet var selectedPlaceLabel: UILabel!
    @IBOutlet var selectedDateLabel: UILabel!
    @IBOutlet var selectedPriorityLabel: UILabel!
    
    

    var selectedBubbleIndex : Int!
    var selectedBubbleName : String!
    var selectedBubblePlace : String!
    var selectedBubbleDate: Date!
    var selectedBubblePriority: Priority!
    
    var delegate : SendBackMyListOfItemsFromBubblesToView?
    var secondDelegate : SendBackMyListOfItemsFromBubblesToTable?
    var favouritePlaces = [FavouritePlace]()
    @IBOutlet weak var bubblePicker: BubblePicker!
    var items: [ToDoItem] = []
    var chosenPlaceItems: [ToDoItem] = []
    var allItems: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeLabel.text = chosenPlace
        if chosenPlace == ""
        {
           placeLabel.text = "All Your Bubbles"
        }
        bubblePicker.delegate = self
        editDeleteView.isHidden = true
        if (bubblesFromOnePlace == false)
        {
            items = allItems
        }
        else
        {
            items = chosenPlaceItems
        }
        bubblePicker.loadData()
    }

    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAddFromBubbles", sender: self)
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.toDoListArrayReceivedFromBubbles(listOfItems:allItems)
        secondDelegate?.toDoListArrayReceivedFromBubblesToTable(listOfItems: allItems)
        dismiss(animated: true, completion:nil)
    }
}
    extension BubblesViewController : BubblePickerDelegate{
        func numberOfItems(in bubblepicker: BubblePicker) -> Int {
            return items.count
        }
        
        func bubblePicker(_: BubblePicker, nodeFor indexPath: IndexPath) -> BubblePickerNode {
            
            var chosenSize: CGFloat = 100.0
            //print("Czas \(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970))")
            let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
            //print("Wysokosc: \(screenHeight)")

            //mniejsze niz dzien
            if(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970 < 86386.805)
            {
                //print("Item: \(items[indexPath.row].item) Liczba: \(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970)")
                chosenSize = 130.0
                if(screenHeight>1000)
                {
                    chosenSize = 200
                }
            }
            //mniejsze niz tydzien
             if(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970 < 604760.39 && items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970 >= 86386.805 )
            {
               // print("Item: \(items[indexPath.row].item) Liczba: \(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970)")
                chosenSize = 100.0
                if(screenHeight>1000)
                {
                    chosenSize = 170
                }
            }
                //wieksze niz tydzien
             if(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970 >= 604760.39)
            {
               // print("Item: \(items[indexPath.row].item) Liczba: \(items[indexPath.row].date.timeIntervalSince1970 - Date().timeIntervalSince1970)")
                chosenSize = 80.0
                if(screenHeight>1000)
                {
                    chosenSize = 150
                }
            }

           // print("Size: \(chosenSize)")
            let node = BubblePickerNode(title: items[indexPath.row].item, color: UIColor.purple, image: UIImage(named: "gradient2.jpg")!, size: chosenSize, pickedTimesSize: 1.2)
            
            if items[indexPath.row].priority == Priority.Low
            {
                node.backgroundColor = lowColor
            }
            if items[indexPath.row].priority == Priority.Medium
            {
                node.backgroundColor = mediumColor
            }
            if items[indexPath.row].priority == Priority.High
            {
                node.backgroundColor = highColor
            }
            
            
            return node
        }
        
        func bubblePicker(_: BubblePicker, didSelectNodeAt indexPath: IndexPath) {
            editDeleteView.isHidden = false
            view.bringSubviewToFront(editDeleteView)
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            
             selectedBubbleIndex = indexPath.row
             selectedBubbleName = items[indexPath.row].item
             selectedBubblePlace = items[indexPath.row].placeName
             selectedBubbleDate = items[indexPath.row].date
             selectedBubblePriority = items[indexPath.row].priority
            
         setSelectedLabels(name:selectedBubbleName,place:selectedBubblePlace,date:dateFormatter.string(from:selectedBubbleDate),priority:selectedBubblePriority.rawValue)
        
        }
        
        func bubblePicker(_: BubblePicker, didDeselectNodeAt indexPath: IndexPath) {
            editDeleteView.isHidden = true
            setSelectedLabels(name: "-", place: "-", date: "-", priority: "-")
            editDeleteView.isHidden=true
            return
        }
        
        func addItem(){
            bubblePicker.deleteAllItems()
            bubblePicker.loadData()
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToAddFromBubbles"
            {
                let addVC = segue.destination as! AddItemViewController
                addVC.allMyItems = allItems
                addVC.shownItems = items
                addVC.favouritePlaces = favouritePlaces
                addVC.delegate = self
                addVC.fromWhichPlaceAdding = chosenPlace
                addVC.isEditingBubble = isEditingBubble
                if selectedBubbleIndex != nil{
                addVC.indexOfEditedBubble = selectedBubbleIndex
                }
            }
        }
        func setSelectedLabels(name:String,place:String,date:String,priority:String)
        {
            selectedNameLabel.text = "Name: \(name)"
            selectedPlaceLabel.text = "Place:  \(place)"
            selectedDateLabel.text = "Date: \(date)"
            selectedPriorityLabel.text = "Priority: \(priority)"
        }
        @IBAction func editBubblePressed(_ sender: UIButton) {
            isEditingBubble = true
            performSegue(withIdentifier: "goToAddFromBubbles", sender: self)
            //self.setSelectedLabels(name: "-", place: "-", date: "-", priority: "-")
            editDeleteView.isHidden = true
            isEditingBubble = false
        }
        
        @IBAction func deleteBubblePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this item? \(selectedBubbleName!)", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel){
                action in
            }
            
        let yes = UIAlertAction(title: "Yes", style: .default){
            action in
            //deleting from all items
                var index = 0
                for element in self.allItems
                {
                      if  self.items[self.selectedBubbleIndex].placeName == element.placeName && self.items[self.selectedBubbleIndex].item == element.item && self.items[self.selectedBubbleIndex].date == element.date
                    {
                       self.allItems.remove(at: index)
    
                    }
                    else
                      {
                        index = index + 1
                    }
                }
            //deleting from shownItems (Bubbles)
              for i in 0...self.items.count
              {
                if i == self.selectedBubbleIndex
                {
                    self.items.remove(at: i)
                }
              }
            self.bubblePicker.deleteAllItems()
            self.bubblePicker.loadData()
            self.saveItemToPlist()
            self.editDeleteView.isHidden = true
           // self.setSelectedLabels(name: "-", place: "-", date: "-", priority: "-")
           // print("All items: \(self.allItems)")
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert,animated: true, completion: nil)
      }
        
        func saveItemToPlist()
        {
            let encoder = PropertyListEncoder()
            do {
                let data = try encoder.encode(self.items)
                try data.write(to:self.dataFilePath!)
            }
            catch {
                print("Error encoding item array \(error)")
            }
        }
}
extension BubblesViewController: SendBackMyListOfItems
{
    func toDoListArrayReceived(listOfItems: [ToDoItem], addedPlace: String) {
        addedBubblePlace = addedPlace
        allItems = listOfItems
        
        if (bubblesFromOnePlace == true)
        {
            let tmpArray = listOfItems.filter(){
                if $0.placeName == chosenPlace{
                    return true
                }else{
                    return false
                }
            }
            items = tmpArray
        }
        else
        {
            items = allItems
        }
        //print("Items: \(items)")
        addItem()
        //print("IS EDITING BUBBLE \(isEditingBubble)")
        isEditingBubble=false
        }
}



