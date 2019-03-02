//
//  AddItemViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 18/02/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import UIKit

protocol SendBackMyListOfItems
{
    func toDoListArrayReceived(listOfItems:[ToDoItem], addedPlace: String)
}

//protocol SendBackMyListOfItemsToTable
//{
//    func toDoListArrayReceived(listOfItems:[ToDoItem])
//}

class AddItemViewController: UIViewController {
    var isEditingBubble = false
    var indexOfEditedBubble: Int!
    var favouritePlaces = [FavouritePlace]()
    var selectedRow : IndexPath!
    @IBOutlet var myTable: UITableView!
   // var segueFromTable = false
    
    var delegate : SendBackMyListOfItems?
    //var tabledelegate : SendBackMyListOfItemsToTable?
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItems.plist")
    
    var allMyItems = [ToDoItem]()
    var shownItems = [ToDoItem]()
    @IBOutlet var alertLabel: UILabel!
    
    @IBOutlet var itemTextField: UITextField!
    @IBOutlet var itemDataPicker: UIDatePicker!
    
    
    var chosenPriority:Priority!
    var chosenDate:Date!
    var chosenItemName:String!
    var chosenPlaceName:String!
    
    //for comparing later
    var savedChosenPriority:Priority!
    var savedChosenDate:Date!
    var savedChosenItemName:String!
    var savedChosenPlaceName:String!
    
    @IBOutlet var youHaveChosenThisPlaceLabel: UILabel!
    @IBOutlet var chosenPriorityLabel: UILabel!
    
    @IBOutlet var addItemView: UIView!
    @IBOutlet var addDateView: UIView!
    @IBOutlet var addPriorityView: UIView!
    @IBOutlet var addPlaceNameView: UIView!
    
    var activeSubview : UIView!
    
    @IBOutlet var deadlineNextButton: UIButton!
    @IBOutlet var itemNextButton: UIButton!
    @IBOutlet var priorityDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isEditingBubble==true)
        {
            itemTextField.text = shownItems[indexOfEditedBubble].item
            itemDataPicker.date = shownItems[indexOfEditedBubble].date
            chosenPriority = shownItems[indexOfEditedBubble].priority
            chosenPlaceName = shownItems[indexOfEditedBubble].placeName
            youHaveChosenThisPlaceLabel.text = "You have chosen \(shownItems[indexOfEditedBubble].placeName)"
            chosenPriorityLabel.text = "Chosen priority: \(shownItems[indexOfEditedBubble].priority.rawValue)"
            savedChosenPriority = chosenPriority
            savedChosenDate = shownItems[indexOfEditedBubble].date
            savedChosenPlaceName = chosenPlaceName
            savedChosenItemName =  shownItems[indexOfEditedBubble].item
            
        }
        print("hello")
        //chosenPlaceName = "Noname"
        if(isEditing == false /*&& segueFromTable==false*/)
        {
        chosenPriority = Priority.Low
        chosenPlaceName = "Noname"
        }
        activeSubview = addItemView
        animateIn(thisSubview:activeSubview)
        //animateIn(thisSubview:addPlaceNameView)
        changeAppearance()
        //print("Favourite Places \(favouritePlaces)")
        // Do any additional setup after loading the view.
    }
    func animateIn(thisSubview:UIView)
    {
        self.view.addSubview(thisSubview)
        thisSubview.center = self.view.center
        thisSubview.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
        thisSubview.alpha = 0
        
        UIView.animate(withDuration:0.4) {
            thisSubview.alpha = 1
            thisSubview.transform = CGAffineTransform.identity
        }
    }
    func animateOut(thisSubview:UIView)
    {
        UIView.animate(withDuration: 0.3, animations: {
            thisSubview.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
            thisSubview.alpha = 0
            thisSubview.removeFromSuperview()
        })
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if sender.tag == 0
        {
            if itemTextField.text!.count>1 {
            chosenItemName = itemTextField.text
            alertLabel.text = ""
            animateOut(thisSubview:activeSubview)
            activeSubview = addDateView
            animateIn(thisSubview:activeSubview)
            }
            else
            {
               alertLabel.text = "Item name is too short"
            }
        }
        else if sender.tag == 1
        {
            chosenDate = itemDataPicker.date
            animateOut(thisSubview:activeSubview)
            if (chosenPlaceName == "Noname" /*&& segueFromTable == false*/)
            {
                activeSubview = addPlaceNameView
                animateIn(thisSubview:activeSubview)
            }
            else
            {
                //segueFromTable = false
                activeSubview = addPriorityView
                animateIn(thisSubview:activeSubview)
            }
        }
        else if sender.tag == 3
        {
            if(selectedRow != nil)
            {
                myTable.deselectRow(at: selectedRow, animated: true)
            }
            animateOut(thisSubview:activeSubview)
            activeSubview = addPriorityView
            animateIn(thisSubview:activeSubview)
        }
        else if sender.tag == 2
        {
            animateOut(thisSubview:activeSubview)
            activeSubview = nil
            youHaveChosenThisPlaceLabel.text = "No place is chosen"
            saveItemToArray()
            isEditingBubble=false
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        animateOut(thisSubview:activeSubview)
        youHaveChosenThisPlaceLabel.text = "No place is chosen"
        chosenPlaceName = "Noname"
        alertLabel.text = ""
        if(selectedRow != nil)
        {
            myTable.deselectRow(at: selectedRow, animated: true)
        }
        isEditingBubble=false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePriority(_ sender: UIButton) {
       if sender.titleLabel!.text == "Low"
       {
        chosenPriority = Priority.Low
        chosenPriorityLabel.text = "Chosen priority: Low"
       }
        else if sender.titleLabel!.text == "Medium"
       {
        chosenPriority = Priority.Medium
        chosenPriorityLabel.text = "Chosen priority: Medium"
       }
        else if sender.titleLabel!.text == "High"
       {
        chosenPriority = Priority.High
        chosenPriorityLabel.text = "Chosen priority: High"
        }
        print(chosenPriority)
    }
    func changeAppearance(){
        let tabela = [addItemView,addDateView,addPriorityView,addPlaceNameView]
        for chosenView in tabela
        {
        chosenView!.layer.cornerRadius = 10
        chosenView!.layer.borderWidth = 1
        chosenView!.layer.borderColor =  UIColor.black.cgColor
        }
    }
    func saveItemToArray()
    {
        let newItem = ToDoItem(placeName: chosenPlaceName, item: chosenItemName, priority: chosenPriority,date: chosenDate)
        if (isEditingBubble==false)
        {
        allMyItems.append(newItem)
        }
       else
        {
            for i in 0...allMyItems.count-1
            {
                print("Z tabeli: \(allMyItems[i].item)")
                print("Zapisane: \(savedChosenItemName)")
                if(savedChosenItemName == allMyItems[i].item && savedChosenPlaceName == allMyItems[i].placeName && savedChosenDate == allMyItems[i].date)
                {
                    allMyItems[i] = newItem
                    print("WESZLOOOOO")
                }
//                if(indexOfEditedBubble == i)
//                {
//                    allMyItems[i] = newItem
//                }
            }
        }
        print("NEW ITEM \(newItem)")
            delegate?.toDoListArrayReceived(listOfItems:allMyItems,addedPlace:chosenPlaceName!)
        //tabledelegate?.toDoListArrayReceived(listOfItems: allMyItems)
        saveItemToPlist()
    }
    func saveItemToPlist()
    {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.allMyItems)
            try data.write(to:self.dataFilePath!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
    }
    
    @IBAction func chooseNoNameButtonPressed(_ sender: UIButton) {
        youHaveChosenThisPlaceLabel.text = "No place is chosen"
        chosenPlaceName = "Noname"
        if(selectedRow != nil)
        {
        myTable.deselectRow(at: selectedRow, animated: true)
        }
    }
}
extension AddItemViewController : UITableViewDelegate
{
    
}
extension AddItemViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        youHaveChosenThisPlaceLabel.text = "You have chosen \(favouritePlaces[indexPath.row].name)"
        chosenPlaceName = favouritePlaces[indexPath.row].name
        self.selectedRow = indexPath
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        youHaveChosenThisPlaceLabel.text = "No place is chosen"
        chosenPlaceName = "Noname"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellInView")
        cell.textLabel?.text = favouritePlaces[indexPath.row].name
        return cell
    }
    
    
}
