//
//  Inventory.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 28.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import Foundation

protocol InventoryDelegate {
    func inventoryDidChange()
}

class Inventory {
    var delegate: InventoryDelegate?
    var items =  [Item]()
    func addItem(_ item: Item) {
        items.append(item)
        delegate?.inventoryDidChange()
    }
    func getItem(_ needItem: Item) -> Item? {
        for index in items.indices {
            if items[index] === needItem {
                let currentItem = items[index]
                items.remove(at: index)
                delegate?.inventoryDidChange()
                return currentItem
            }
        }
        return nil
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
