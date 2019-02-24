//
//  Others.swift
//  BubbleRemindingProject
//
//  Created by Aleksandra Konopka on 24/02/2019.
//  Copyright © 2019 Aleksandra Konopka. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable extension UIButton{
    @IBInspectable var cornerRadius : CGFloat{
        set{
            layer.cornerRadius = newValue
        }
        get{
            return layer.cornerRadius
        }
    }
    @IBInspectable var cornerWidth : CGFloat{
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
    }
}
