//
//  BubblesViewController.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 14/02/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import UIKit

class BubblesViewController: UIViewController {

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
           // addItem()
            if items[indexPath.row].item == "dupa"
            {
                addItem()
                //bubblePicker.changeNodeSize(indexPath: indexPath)
            }
        
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
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


