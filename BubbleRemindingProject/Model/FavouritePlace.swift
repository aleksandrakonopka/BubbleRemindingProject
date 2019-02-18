//
//  FavouritePlace.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 08/12/2018.
//  Copyright © 2018 Aleksandra Konopka. All rights reserved.
//

import Foundation
import UIKit

struct FavouritePlace : Codable {
    var name: String
    var long: Double
    var lat: Double
    
    init(name: String, long: Double, lat: Double){
        self.name = name
        self.long = long
        self.lat = lat
    }
    //dodac pustego inita jesli chce stworzc tablice pusta 
}
