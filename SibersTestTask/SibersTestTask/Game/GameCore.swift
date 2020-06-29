//
//  GameCore.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 23.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import Foundation

protocol GameDelegate: AnyObject {
    func currentRoomDidChange()
    func inventoryDidChange()
    func roomItemsDidChange()
    func gameStateDidChange()
    func healthPointsDidChange()
    func moneyCountDidChange()
}

enum GameState: Int {
    case started, win, deadFromHunger
}

final class Game: RoomDelegate, InventoryDelegate {
    var gameField: GameField
    weak var gameDelegate: GameDelegate?
    var playerInventory: Inventory
    var playerMoney: Int {
        didSet {
            gameDelegate?.moneyCountDidChange()
        }
    }
    var gameState: GameState = .started {
        didSet {
            gameDelegate?.gameStateDidChange()
        }
    }
    
    var healthPoints: Int = 0 {
        didSet {
            gameDelegate?.healthPointsDidChange()
        }
    }
    
    var currentRoomPosition: RoomPosition {
        didSet {
            gameDelegate?.currentRoomDidChange()
        }
    }
    
    init(roomsInRow: Int, roomsInColumn: Int) {
        gameField = GameField(roomsInRow: roomsInRow, roomsInColumn: roomsInColumn)
        currentRoomPosition = (Int.random(in: 1...roomsInRow), Int.random(in: 1...roomsInColumn)) //put player in random room
        playerInventory = Inventory()
        playerMoney = 0
        healthPoints = roomsInRow*roomsInColumn*3
        
        playerInventory.delegate = self
        getCurrentRoom()?.roomDelegate = self
        gameField.printMaze()
    }
    
    func getCurrentRoom() -> Room? {
        return gameField.getRoom(at: currentRoomPosition)
    }
    func enterDoor(_ door: Door) -> Bool {
        if healthPoints <= 0 {
            return false
        }
        guard let room = getCurrentRoom() else {
            return false
        }
        if room.haveDoor(door) {
            switch door {
            case .left:
                currentRoomPosition.x -= 1
            case .right:
                currentRoomPosition.x += 1
            case .down:
                currentRoomPosition.y += 1
            case .up:
                currentRoomPosition.y -= 1
            }
            room.roomDelegate = nil
            getCurrentRoom()?.roomDelegate = self
            removeHealthPoints(count: 1)
            return true
        }
        return false
    }
    func removeHealthPoints(count: Int) {
        healthPoints -= count
        if healthPoints <= 0 {
            gameState = .deadFromHunger
        }
    }

    func takeItemFromRoom(itemId id: ItemId) -> Bool {
        guard let foundItem = getCurrentRoom()?.findItemById(id) as? TakebleItem else {
            return false
        }
        return foundItem.take(currentGame: self)
    }
    func dropItemInRoom(itemId id: ItemId) -> Bool {
        guard let foundItem = playerInventory.findItemById(id) as? DropableItem else {
            return false
        }
        return foundItem.drop(currentGame: self)
    }
    func destroyItemFromInventory(itemId id: ItemId) -> Bool {
        guard let foundItem = playerInventory.findItemById(id) as? DestroyableItem else {
            return false
        }
        return foundItem.destroy(currentGame: self)
    }
    func useItemFromInventory(itemId id: ItemId) -> Bool {
        guard let foundItem = playerInventory.findItemById(id) as? UsableItem else {
            return false
        }
        return foundItem.use(currentGame: self)
    }
    
    func roomItemsDidChange() {
        self.gameDelegate?.roomItemsDidChange()
    }
    func inventoryDidChange() {
        self.gameDelegate?.inventoryDidChange()
    }
}
