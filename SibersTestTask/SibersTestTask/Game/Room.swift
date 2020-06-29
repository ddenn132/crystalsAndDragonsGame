//
//  Room.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 28.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import Foundation


typealias RoomPosition = (x: Int, y: Int)

enum Door {
    case left, right, up, down
}

protocol RoomDelegate: AnyObject {
    func roomItemsDidChange()
}

final class Room {
    weak var roomDelegate: RoomDelegate?
    var doors = [Door]()
    var items = [Item]() {
        didSet {
            roomDelegate?.roomItemsDidChange()
        }
    }
        
    func putItem(_ item: DropableItem) {
        items.append(item)
    }
    
    func takeItem(_ item: TakebleItem) -> Item? {
        for index in items.indices {
            if items[index] === item {
                let currentItem = items[index]
                items.remove(at: index)
                return currentItem
            }
        }
        return nil
    }
    
    func haveAnyDoor() -> Bool {
        return self.doors.count > 0
    }
    
    func haveDoor(_ door: Door) -> Bool {
        return doors.contains(door)
    }
    
    func addDoor(_ door: Door) {
        guard !doors.contains(door) else {
            return
        }
        doors.append(door)
    }
    
    func findItemById(_ id: ItemId) -> Item? {
        for item in items {
            if item.itemId == id {
                return item
            }
        }
        return nil
    }
}
