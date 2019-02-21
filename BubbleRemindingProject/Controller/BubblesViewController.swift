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

class BubblesViewController: UIViewController {
    
    
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
    var favouritePlaces = [FavouritePlace]()
    @IBOutlet weak var bubblePicker: BubblePicker!
    var items: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bubblePicker.delegate = self
        editDeleteView.isHidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAddFromBubbles", sender: self)
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.toDoListArrayReceivedFromBubbles(listOfItems:items)
        dismiss(animated: true, completion:nil)
    }
}
    extension BubblesViewController : BubblePickerDelegate{
        func numberOfItems(in bubblepicker: BubblePicker) -> Int {
            return items.count
        }
        
        func bubblePicker(_: BubblePicker, nodeFor indexPath: IndexPath) -> BubblePickerNode {
            
            var chosenSize: CGFloat = 100.0
            if items[indexPath.row].item == "jajko"
            {
                chosenSize = 50.0
            }
            let node = BubblePickerNode(title: items[indexPath.row].item, color: UIColor.purple, image: UIImage(named: "gradient2.jpg")!, size: chosenSize, pickedTimesSize: 1.2)
            
            if items[indexPath.row].priority == Priority.Low
            {
                node.backgroundColor = UIColor.green
            }
            if items[indexPath.row].priority == Priority.Medium
            {
                node.backgroundColor = UIColor.orange
            }
            if items[indexPath.row].priority == Priority.High
            {
                node.backgroundColor = UIColor.red
            }
            
            
            return node
        }
        
        func bubblePicker(_: BubblePicker, didSelectNodeAt indexPath: IndexPath) {
            editDeleteView.isHidden = false
            // dodac godzine i minuty
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            
             selectedBubbleIndex = indexPath.row
             selectedBubbleName = items[indexPath.row].item
             selectedBubblePlace = items[indexPath.row].placeName
             selectedBubbleDate = items[indexPath.row].date
             selectedBubblePriority = items[indexPath.row].priority
            
         setSelectedLabels(name:selectedBubbleName,place:selectedBubblePlace,date:dateFormatter.string(from:selectedBubbleDate),priority:selectedBubblePriority.rawValue)
           // addItem()
//            if items[indexPath.row].item == "dupa"
//            {
//                addItem()
//                //bubblePicker.changeNodeSize(indexPath: indexPath)
//            }
        
        }
        
        func bubblePicker(_: BubblePicker, didDeselectNodeAt indexPath: IndexPath) {
            editDeleteView.isHidden = true
            setSelectedLabels(name: "-", place: "-", date: "-", priority: "-")
            return
        }
        
        func addItem(){
            //self.items.append("test")
            //bubblePicker.reloadDataAdded()
            bubblePicker.deleteAll(howMuch:items.count-1)
            bubblePicker.loadData()
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToAddFromBubbles"
            {
                let addVC = segue.destination as! AddItemViewController
                addVC.allMyItems = items
                addVC.favouritePlaces = favouritePlaces
                addVC.delegate = self
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
            
        }
        
        @IBAction func deleteBubblePressed(_ sender: UIButton) {
          for i in 0...items.count
          {
            if i == selectedBubbleIndex
            {
                items.remove(at: i)
            }
          }
        bubblePicker.deleteAll(howMuch:items.count+1)
        bubblePicker.loadData()
        saveItemToPlist()
        editDeleteView.isHidden = true
        setSelectedLabels(name: "-", place: "-", date: "-", priority: "-")
        
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
    func toDoListArrayReceived(listOfItems: [ToDoItem]) {
        items = listOfItems
        addItem()
        print("weszlo")
        }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


