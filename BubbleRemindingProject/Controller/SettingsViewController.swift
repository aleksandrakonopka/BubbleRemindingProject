//
//  SettingsViewController.swift
//  BubbleRemindingProject
//
//  Created by Aleksandra Konopka on 03/03/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var mainView: UIView!
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
    @IBAction func changeColorPressed(_ sender: Any) {
        
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
        let tabela = [mainView]
        for chosenView in tabela
        {
            chosenView!.layer.cornerRadius = 10
            chosenView!.layer.borderWidth = 1
            chosenView!.layer.borderColor =  UIColor.black.cgColor
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

}
