//
//  Items.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 27.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import Foundation


enum ItemId: Int {
    case keyForChest = 1, chest, torch, beanbag, stone, mushroom, bone, apple, money
}

class Item {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.itemId == rhs.itemId
    }
    let itemId: ItemId
    let itemName: String
    let itemDecription: String
    let imageName: String?
    init(itemName: String, descriprion: String, id: ItemId, imageName: String) {
        self.itemId = id
        self.itemName = itemName
        self.itemDecription = descriprion
        self.imageName = imageName
    }
}

protocol DropableItem: Item {
    func drop(currentGame game: Game) -> Bool
}

protocol TakebleItem: Item {
    func take(currentGame game: Game)  -> Bool
}

protocol DestroyableItem: Item {
    func destroy(currentGame game: Game) -> Bool
}

protocol UsableItem: Item {
    var destroyAfterUse: Bool {get}
    func use(currentGame game: Game) -> Bool
}

class RoomItemsFiller {
    static let chancesToDrop: [ItemId : Double] = [
        .apple:0.2,
        .beanbag:0.1,
        .bone:0.1,
        .mushroom:0.1,
        .stone:0.1,
        .torch:0.1,
        .money:0.2
        ]
    //set random items in room
    static func fillRoom(room: Room) {
        for element in chancesToDrop {
            if Double.random(in: 0...1) < element.value {
                room.items.append(ItemFactory.getItemById(element.key))
            }
        }
    }
}

class ItemFactory {
    static func getItemById(_ id: ItemId) -> Item{
        switch id {
        case .apple:
            return Apple()
        case .beanbag:
            return BeanBag()
        case .bone:
            return Bone()
        case .chest:
            return Chest()
        case .keyForChest:
            return KeyForChest()
        case .mushroom:
            return Mushroom()
        case .stone:
            return Stone()
        case .torch:
            return Torch()
        case .money:
            return Money()
        }
    }
}

class TakeDropAndDestroyItem: Item, TakebleItem, DropableItem, DestroyableItem {
    func destroy(currentGame game: Game) -> Bool {
        if game.playerInventory.getItem(self) == nil {
            return false
        }
        return true
    }
    
    func take(currentGame game: Game) -> Bool {
        if game.getCurrentRoom()?.takeItem(self) == nil {
            return false
        }
        game.playerInventory.addItem(self)
        return true
    }
    
    func drop(currentGame game: Game) -> Bool {
        if game.playerInventory.getItem(self) == nil {
            return false
        }
        game.getCurrentRoom()?.putItem(self)
        return true
    }
}

final class KeyForChest: TakeDropAndDestroyItem, UsableItem {
    let destroyAfterUse: Bool = true
    init() {
        super.init(itemName: "Ключ от сундука", descriprion: "Используйте этот ключ, чтобы открыть сундук.", id: .keyForChest, imageName: "icons8-key-52")
    }
    func use(currentGame game: Game) -> Bool {
        guard let itemsInRoom = game.getCurrentRoom()?.items else {
            return false
        }
        for item in itemsInRoom {
            if item.itemId == .chest {
                game.gameState = .win
                if destroyAfterUse {
                    _ = self.destroy(currentGame: game)
                }
                return true
            }
        }
        return false
    }
}

final class Chest: Item {
    init() {
        super.init(itemName: "Сундук", descriprion: "Используйте ключ, чтобы открыть сундук", id: .chest, imageName: "icons8-toolbox-52")
    }
}

final class Torch: TakeDropAndDestroyItem {
    init() {
        super.init(itemName: "Факел", descriprion: "Кажется, олимпийский", id: .torch, imageName: "icons8-olympic-torch-52")
    }
}

final class BeanBag: TakeDropAndDestroyItem {
    init() {
        super.init(itemName: "Погремушка", descriprion: "Неплохо шумит", id: .beanbag, imageName: "icons8-rattle-52")
    }
}

final class Stone: TakeDropAndDestroyItem {
    init() {
        super.init(itemName: "Камень", descriprion: "Твердый, но грязный", id: .stone, imageName: "icons8-rock-52")
    }
}

final class Mushroom: TakeDropAndDestroyItem {
    init() {
        super.init(itemName: "Гриб", descriprion: "Несъедобный", id: .mushroom, imageName: "icons8-mushroom-52")
    }
}

final class Bone: TakeDropAndDestroyItem {
    init() {
        super.init(itemName: "Кость", descriprion: "Нормальная такая рыбина была", id: .bone, imageName: "icons8-dog-bone-52")
    }
}


final class Apple: TakeDropAndDestroyItem, UsableItem {
    var destroyAfterUse: Bool = true
    
    func use(currentGame game: Game) -> Bool {
        game.healthPoints += 10
        if destroyAfterUse {
            _ = self.destroy(currentGame: game)
        }
        return true
    }
    
    init() {
        super.init(itemName: "Яблоко", descriprion: "Можно съесть", id: .apple, imageName: "icons8-apple-52")
    }
}

final class Money: TakeDropAndDestroyItem {
    var count: Int = 0
    
    override func take(currentGame game: Game) -> Bool {
        if super.take(currentGame: game) {
            if self.destroy(currentGame: game) {
                game.playerMoney += count
                return true
            }
        }
        return false
    }
    
    init() {
        super.init(itemName: "Деньги", descriprion: "", id: .money, imageName: "icons8-money-52")
        count = Int.random(in: 1...50)
    }
}

