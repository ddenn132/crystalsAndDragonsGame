//
//  GameViewController.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 26.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import UIKit

enum GameError: Int {
    case noDoorToEneter, noSuchInRoom, noSuchItemInInventory, cantDropItem, cantUsetItem, cantDestroyItem
}

final class GameViewController: UIViewController, GameDelegate {
    //MARK: Room doors buttons
    @IBOutlet private var goUpButton: UIButton!
    @IBOutlet private var goDownButton: UIButton!
    @IBOutlet private var goLeftButton: UIButton!
    @IBOutlet private var goRightButton: UIButton!
    //MARK: Room items buttons
    @IBOutlet private var keyRoomButton: UIButton!
    @IBOutlet private var chestRoomButton: UIButton!
    @IBOutlet private var torchRoomButton: UIButton!
    @IBOutlet private var stoneRoomButton: UIButton!
    @IBOutlet private var mushroomRoomButton: UIButton!
    @IBOutlet private var boneRoomButton: UIButton!
    @IBOutlet private var appleRoomButton: UIButton!
    @IBOutlet private var moneyRoomButton: UIButton!
    @IBOutlet private var moneyRoomCountLabel: UILabel!
    //MARK: Inventory items buttons
    @IBOutlet private var keyInventoryButton: UIButton!
    @IBOutlet private var torchInventoryButton: UIButton!
    @IBOutlet private var stoneInventoryButton: UIButton!
    @IBOutlet private var mushroomInventoryButton: UIButton!
    @IBOutlet private var boneInventoryButton: UIButton!
    @IBOutlet private var appleInventoryButton: UIButton!
    //MARK: Inventory item description
    @IBOutlet private var inventoryItemName: UILabel!
    @IBOutlet private var inventoryItemDescription: UILabel!
    //MARK: Inventory item actions buttons
    @IBOutlet private var dropInventoryButton: UIButton!
    @IBOutlet private var destroyInventoryButton: UIButton!
    @IBOutlet private var useInventoryButton: UIButton!
    //MARK: Game info labels
    @IBOutlet private var healthPointsLabel: UILabel!
    @IBOutlet private var moneyCountLabel: UILabel!
    
    var gameModel: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRoom()
        loadInventory()
        healthPointsDidChange()
        moneyCountDidChange()
    }
    
    func setNewGame(_ game: Game) {
        self.gameModel = game
        self.gameModel?.gameDelegate = self
    }
    
    //MARK: userActions: click on room door
    @IBAction private func goRightRoom(_ sender: Any) {
        if !(gameModel?.enterDoor(.right) ?? false){
            showErrorMessage(error: .noDoorToEneter)
        }
    }
    @IBAction private func goLeftRoom(_ sender: Any) {
        if !(gameModel?.enterDoor(.left) ?? false){
            showErrorMessage(error: .noDoorToEneter)
        }
    }
    @IBAction private func goUpRoom(_ sender: Any) {
        if !(gameModel?.enterDoor(.up) ?? false){
            showErrorMessage(error: .noDoorToEneter)
        }
    }
    @IBAction private func goDownRoom(_ sender: Any) {
        if !(gameModel?.enterDoor(.down) ?? false){
            showErrorMessage(error: .noDoorToEneter)
        }
    }
    //MARK: userActions: click on item in room
    @IBAction private func roomItemClick(_ sender: UIButton) {
        var isItemTaked = false
        switch sender {
        case keyRoomButton:
            isItemTaked = gameModel?.takeItemFromRoom(itemId: .keyForChest) ?? false
        case torchRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .torch) ?? false)
        case mushroomRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .mushroom) ?? false)
        case stoneRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .stone) ?? false)
        case boneRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .bone) ?? false)
        case appleRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .apple) ?? false)
        case moneyRoomButton:
            isItemTaked = (gameModel?.takeItemFromRoom(itemId: .money) ?? false)
        default:
            return
        }
        if !isItemTaked {
            showErrorMessage(error: .noSuchInRoom)
        }
    }
    //MARK: userActions: click on item in inventory
    @IBAction private func inventoryItemClick(_ sender: UIButton) {
        switch sender {
        case keyInventoryButton:
            loadItemById(.keyForChest)
            selectedInventoryItem = .keyForChest
        case torchInventoryButton:
            loadItemById(.torch)
            selectedInventoryItem = .torch
        case stoneInventoryButton:
            loadItemById(.stone)
            selectedInventoryItem = .stone
        case mushroomInventoryButton:
            loadItemById(.mushroom)
            selectedInventoryItem = .mushroom
        case boneInventoryButton:
            loadItemById(.bone)
            selectedInventoryItem = .bone
        case appleInventoryButton:
            loadItemById(.apple)
            selectedInventoryItem = .apple
        default:
            return
        }
    }
    //MARK: userActions: actions with item in inventory
    @IBAction private func dropItemFromInventory(_ sender: Any) {
        guard let itemToDrop = selectedInventoryItem else {
            return
        }
        if !(gameModel?.dropItemInRoom(itemId: itemToDrop) ?? false) {
            showErrorMessage(error: .cantDropItem)
            return
        }
        selectedInventoryItem = nil
    }
    @IBAction private func destroyItemFromInventory(_ sender: Any) {
        guard let itemToDestroy = selectedInventoryItem else {
            return
        }
        if !(gameModel?.destroyItemFromInventory(itemId: itemToDestroy) ?? false) {
            showErrorMessage(error: .cantDropItem)
            return
        }
        selectedInventoryItem = nil
    }
    @IBAction private func useItemFromInventory(_ sender: Any) {
        guard let itemToUse = selectedInventoryItem else {
            return
        }
        if !(gameModel?.useItemFromInventory(itemId: itemToUse) ?? false) {
            showErrorMessage(itemId: itemToUse, error: .cantUsetItem)
            return
        }
        selectedInventoryItem = nil
    }
    
    
    
    
    //MARK: viewChangeFunctions
    //MARK: viewChange: load room view functions
    private func loadRoom() {
        loadRoomDoors()
        loadRoomItems()
    }
    
    private func loadRoomDoors() {
        goUpButton.isHidden = !(gameModel?.getCurrentRoom()?.haveDoor(.up) ?? false)
        goDownButton.isHidden = !(gameModel?.getCurrentRoom()?.haveDoor(.down) ?? false)
        goLeftButton.isHidden = !(gameModel?.getCurrentRoom()?.haveDoor(.left) ?? false)
        goRightButton.isHidden = !(gameModel?.getCurrentRoom()?.haveDoor(.right) ?? false)
    }
    
    private func loadRoomItems() {
        keyRoomButton.isHidden       = true
        chestRoomButton.isHidden     = true
        torchRoomButton.isHidden     = true
        mushroomRoomButton.isHidden  = true
        stoneRoomButton.isHidden     = true
        boneRoomButton.isHidden      = true
        appleRoomButton.isHidden     = true
        moneyRoomButton.isHidden     = true
        moneyRoomCountLabel.isHidden = true
        
        guard let roomItems = gameModel?.getCurrentRoom()?.items else {
            return
        }
        for item in roomItems {
            switch item {
            case is KeyForChest:
                keyRoomButton.isHidden = false
            case is Chest:
                chestRoomButton.isHidden = false
            case is Torch:
                torchRoomButton.isHidden = false
            case is Stone:
                stoneRoomButton.isHidden = false
            case is Mushroom:
                mushroomRoomButton.isHidden = false
            case is Bone:
                boneRoomButton.isHidden = false
            case is Apple:
                appleRoomButton.isHidden = false
            case is Money:
                guard let moneyItem = item as? Money else {
                    continue
                }
                moneyRoomButton.isHidden = false
                moneyRoomCountLabel.text = String(moneyItem.count)
                moneyRoomCountLabel.isHidden = false
            default:
                continue
            }
        }
    }
    //MARK: viewChange: load inventory view functions
    private func loadInventory() {
        keyInventoryButton.isHidden = true
        torchInventoryButton.isHidden = true
        stoneInventoryButton.isHidden = true
        mushroomInventoryButton.isHidden = true
        boneInventoryButton.isHidden = true
        appleInventoryButton.isHidden = true
        
        guard let inventoryItems = gameModel?.playerInventory.items else {
            return
        }
        
        for item in inventoryItems {
            switch item {
            case is KeyForChest:
                keyInventoryButton.isHidden = false
            case is Torch:
                torchInventoryButton.isHidden = false
            case is Stone:
                stoneInventoryButton.isHidden = false
            case is Mushroom:
                mushroomInventoryButton.isHidden = false
            case is Bone:
                boneInventoryButton.isHidden = false
            case is Apple:
                appleInventoryButton.isHidden = false
            default:
                continue
            }
        }
    }
    
    private var selectedInventoryItem: ItemId? { //storage itemId, that choosed by user in inventory
        didSet {
            if selectedInventoryItem == nil {
                clearInventoryItemMenu()
            }
        }
    }
    //show item descripiton and actions buttons
    private func loadItemById(_ id: ItemId) {
        //show actions buttons that deoends on item class
        func setInventoryButtonsByClass(_ itemType: Item.Type) {
            if itemType as? UsableItem.Type != nil {
                useInventoryButton.isHidden = false
            }
            if itemType as? DropableItem.Type != nil {
                dropInventoryButton.isHidden = false
            }
            if itemType as? DestroyableItem.Type != nil {
                destroyInventoryButton.isHidden = false
            }
        }
        clearInventoryItemMenu()
        let item = gameModel?.playerInventory.findItemById(id)
        inventoryItemName.text = item?.itemName
        inventoryItemDescription.text = item?.itemDecription
        switch id {
        case .keyForChest:
            keyInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(KeyForChest.self)
        case .torch:
            torchInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(Torch.self)
        case .stone:
            stoneInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(Stone.self)
        case .mushroom:
            mushroomInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(Mushroom.self)
        case .bone:
            boneInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(Bone.self)
        case .apple:
            appleInventoryButton.backgroundColor = UIColor.systemGray
            setInventoryButtonsByClass(Apple.self)
        default:
            return
        }
        return
    }
    
    private func clearInventoryItemMenu() {
        keyInventoryButton.backgroundColor = UIColor.clear
        stoneInventoryButton.backgroundColor = UIColor.clear
        torchInventoryButton.backgroundColor = UIColor.clear
        mushroomInventoryButton.backgroundColor = UIColor.clear
        boneInventoryButton.backgroundColor = UIColor.clear
        appleInventoryButton.backgroundColor = UIColor.clear
        inventoryItemName.text = nil
        inventoryItemDescription.text = nil
        dropInventoryButton.isHidden = true
        destroyInventoryButton.isHidden = true
        useInventoryButton.isHidden = true
    }
    
    //MARK: delegateFunctions
    func currentRoomDidChange() {
        loadRoom()
    }
    
    func inventoryDidChange() {
        loadInventory()
    }
    
    func roomItemsDidChange() {
        loadRoomItems()
    }
    
    func gameStateDidChange() {
        switch gameModel?.gameState {
        case .deadFromHunger:
            let alert = UIAlertController(title: "Смерть", message: "Вы погибли от голодной смерти.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Выйти в меню", style: .default, handler: {
                action in

                self.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true)
        case .win:
            let alert = UIAlertController(title: "Победа!", message: "Поздравляем! Вы открыли сундук!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Выйти в меню", style: .default, handler: {
                action in

                self.dismiss(animated: true, completion: nil)
            } ))

            self.present(alert, animated: true)
        default:
            return
        }
    }
    
    func healthPointsDidChange() {
        healthPointsLabel.text = String(gameModel?.healthPoints ?? 0)
    }
    
    func moneyCountDidChange() {
        moneyCountLabel.text = String(gameModel?.playerMoney ?? 0)
    }

    func showErrorMessage(error: GameError) {
        print(error)
        return
    }
    
    func showErrorMessage(itemId: ItemId, error: GameError) {
        if itemId == .keyForChest && error == .cantUsetItem {
            showInfoAlert(infoTitle: "Ключ", info: "Поблизости нет сундука")
        }
    }
    
    func showInfoAlert(infoTitle: String, info: String) {
        let alert = UIAlertController(title: infoTitle, message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понял", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
