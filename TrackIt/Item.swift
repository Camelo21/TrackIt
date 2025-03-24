//
//  Item.swift
//  TrackIt
//
//  Created by Camilo Melo bernal on 23/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
