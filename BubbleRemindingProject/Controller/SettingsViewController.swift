//
//  SettingsViewController.swift
//  BubbleRemindingProject
//
//  Created by Aleksandra Konopka on 03/03/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

var lowColor = UIColor.green
var mediumColor = UIColor.orange
var highColor = UIColor.red

import UIKit

class SettingsViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet var mainView: UIView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var priorityColorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateIn(thisSubview: mainView)
        changeAppearance()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        animateOut(thisSubview: mainView)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changeColorPressed(_ sender: UIButton) {
        animateOut(thisSubview: mainView)
        animateIn(thisSubview: colorView)
        if sender.tag == 0
        {
        priorityColorLabel.text = "Low"
        priorityColorLabel.backgroundColor = lowColor
        }
        else if sender.tag == 1
        {
        priorityColorLabel.text = "Medium"
        priorityColorLabel.backgroundColor = mediumColor
        }
        else{
        priorityColorLabel.text = "High"
        priorityColorLabel.backgroundColor = highColor
        }
        
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
    func changeAppearance(){
        let tabela = [mainView,colorView]
        for chosenView in tabela
        {
            chosenView!.layer.cornerRadius = 10
            chosenView!.layer.borderWidth = 1
            chosenView!.layer.borderColor =  UIColor.black.cgColor
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        animateOut(thisSubview: colorView)
        animateIn(thisSubview: mainView)
        if priorityColorLabel.text == "Low"
        {
            lowColor = priorityColorLabel.backgroundColor!
            defaults.setColor(color:lowColor, forKey: "LowColor")
        }
        else if  priorityColorLabel.text == "Medium"
        {
            mediumColor = priorityColorLabel.backgroundColor!
            defaults.setColor(color:mediumColor, forKey: "MediumColor")
        }
        else
        {
            highColor = priorityColorLabel.backgroundColor!
            defaults.setColor(color:highColor, forKey: "HighColor")
        }
        print("Low \(lowColor)")
        print("Medium \(mediumColor)")
        print("High \(highColor)")
    }
    
    @IBAction func pickColorPressed(_ sender: UIButton) {
            priorityColorLabel.backgroundColor=sender.backgroundColor
            print(priorityColorLabel.backgroundColor)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
    
}
