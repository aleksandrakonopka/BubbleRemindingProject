//
//  ToDoItem.swift
//  GetYourFavouritePlaces
//
//  Created by Aleksandra Konopka on 29/12/2018.
//  Copyright © 2018 Aleksandra Konopka. All rights reserved.
//
import Foundation
import UIKit
enum Priority : String, Codable {
    case Medium = "Medium"
    case High = "High"
    case Low = "Low"
}
struct ToDoItem:Codable {
    var placeName: String
    var item: String
    var priority : Priority
    var date : Date
    init(placeName: String, item: String, priority: Priority, date: Date) {
        self.placeName = placeName
        self.item = item
        self.priority = priority
        self.date = date
    }
}
