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
            let node = BubblePickerNode(title: items[indexPath.row].item, color: UIColor.purple, image: UIImage(named: "ipad.jpg")!, size: chosenSize, pickedTimesSize: 1.6)
            
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
             selectedBubbleIndex = indexPath.row
             selectedBubbleName = items[indexPath.row].item
             selectedBubblePlace = items[indexPath.row].placeName
             selectedBubbleDate = items[indexPath.row].date
             selectedBubblePriority = items[indexPath.row].priority
            
         setSelectedLabels(name:selectedBubbleName,place:selectedBubblePlace,date:selectedBubbleDate,priority:selectedBubblePriority)
           // addItem()
//            if items[indexPath.row].item == "dupa"
//            {
//                addItem()
//                //bubblePicker.changeNodeSize(indexPath: indexPath)
//            }
        
        }
        
        func bubblePicker(_: BubblePicker, didDeselectNodeAt indexPath: IndexPath) {
            return
        }
        
        func addItem(){
            //self.items.append("test")
            //bubblePicker.reloadDataAdded()
            bubblePicker.deleteAll()
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
        func setSelectedLabels(name:String,place:String,date:Date,priority:Priority)
        {
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy" // dodac godzine i minuty
            selectedNameLabel.text = "Name: \(name)"
            selectedPlaceLabel.text = "Place:  \(place)"
            selectedDateLabel.text = "Date: \(dateFormatter.string(from:date))"
            selectedPriorityLabel.text = "Priority: \(priority.rawValue)"
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


