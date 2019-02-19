//
//  AddItemViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 18/02/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    
    @IBOutlet var alertLabel: UILabel!
    
    @IBOutlet var itemTextField: UITextField!
    @IBOutlet var itemDataPicker: UIDatePicker!
    
    
    var chosenPriority:Priority!
    var chosenDate:Date!
    var chosenItemName:String!
    var chosenPlaceName: String!
    
    @IBOutlet var chosenPriorityLabel: UILabel!
    @IBOutlet var addItemView: UIView!
    @IBOutlet var addDateView: UIView!
    @IBOutlet var addPriorityView: UIView!
    var activeSubview : UIView!
    
    @IBOutlet var deadlineNextButton: UIButton!
    @IBOutlet var itemNextButton: UIButton!
    @IBOutlet var priorityDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chosenPlaceName = "Noname"
        chosenPriority = Priority.Low
        activeSubview = addItemView
        animateIn(thisSubview:activeSubview)
        changeAppearance()
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
            activeSubview = addPriorityView
            animateIn(thisSubview:activeSubview)
        }
        else if sender.tag == 2
        {
            animateOut(thisSubview:activeSubview)
            activeSubview = nil
            saveItemToPlist()
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        animateOut(thisSubview:activeSubview)
        alertLabel.text = ""
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
        let tabela = [addItemView,addDateView,addPriorityView]
        for chosenView in tabela
        {
        chosenView!.layer.cornerRadius = 10
        chosenView!.layer.borderWidth = 1
        chosenView!.layer.borderColor =  UIColor.black.cgColor
        }
    }
    func saveItemToPlist()
    {
        print(chosenPlaceName)
        print(chosenDate)
        print(chosenItemName)
        print(chosenPriority)
    }
}
