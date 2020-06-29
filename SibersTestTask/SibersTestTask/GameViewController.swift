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
    @IBOutlet var roomItemsCollectionView: UICollectionView!
    @IBOutlet var inventoryItemsCollectionView: UICollectionView!
    
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
        roomItemsCollectionView?.delegate = self
        roomItemsCollectionView?.dataSource = self
        inventoryItemsCollectionView?.dataSource = self
        inventoryItemsCollectionView?.delegate = self
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
        if !(gameModel?.enterDoor(.right) ?? false) {
            showErrorMessage(error: .noDoorToEneter)
        }
    }
    @IBAction private func goLeftRoom(_ sender: Any) {
        if !(gameModel?.enterDoor(.left) ?? false) {
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
    //MARK: userActions: actions with item in inventory
    @IBAction private func dropItemFromInventory(_ sender: Any) {
        guard let itemToDrop = selectedInventoryItem as? DropableItem else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        guard let game = gameModel else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        if !itemToDrop.drop(currentGame: game) {
            showErrorMessage(error: .cantDropItem)
        }
        selectedInventoryItem = nil
    }
    @IBAction private func destroyItemFromInventory(_ sender: Any) {
        guard let itemToDrop = selectedInventoryItem as? DestroyableItem else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        guard let game = gameModel else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        if !itemToDrop.destroy(currentGame: game) {
            showErrorMessage(error: .cantDropItem)
        }
        selectedInventoryItem = nil
    }
    @IBAction private func useItemFromInventory(_ sender: Any) {
        guard let itemToDrop = selectedInventoryItem as? UsableItem else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        guard let game = gameModel else {
            showErrorMessage(error: .cantDropItem)
            return
        }
        if !itemToDrop.use(currentGame: game) {
            showErrorMessage(error: .cantDropItem)
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
        roomItemsCollectionView.reloadData()
    }
    //MARK: viewChange: load inventory view functions
    private func loadInventory() {
        inventoryItemsCollectionView.reloadData()
    }
    
    private var selectedInventoryItem: Item? { //storage itemId, that choosed by user in inventory
        didSet {
            if selectedInventoryItem == nil {
                clearInventoryItemMenu()
                loadInventory()
            }
        }
    }
    private func showItemMenuInInventory(item: Item) {
        clearInventoryItemMenu()
        inventoryItemName.text = item.itemName
        inventoryItemDescription.text = item.itemDecription
        if let _ = item as? UsableItem {
            useInventoryButton.isHidden = false
        }
        if let _ = item as? DropableItem {
            dropInventoryButton.isHidden = false
        }
        if let _ = item as? DestroyableItem {
            destroyInventoryButton.isHidden = false
        }
    }
    private func clearInventoryItemMenu() {
        print("clear")
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

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case roomItemsCollectionView:
            return gameModel?.getCurrentRoom()?.items.count ?? 0
        case inventoryItemsCollectionView:
            return gameModel?.playerInventory.items.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case roomItemsCollectionView:
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomViewCell", for: indexPath) as? RoomCollectionViewCell {
                if let item = gameModel?.getCurrentRoom()?.items[indexPath.row] {
                    itemCell.setItem(item: item)
                    itemCell.delegate = self
                }
                return itemCell
            }
        case inventoryItemsCollectionView:
            if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "inventoryItemCell", for: indexPath) as? InventoryCollectionViewCell {
                if let item = gameModel?.playerInventory.items[indexPath.row] {
                    itemCell.setItem(item: item)
                    itemCell.delegate = self
                }
                return itemCell
            }
        default:
            return UICollectionViewCell()
        }

        return UICollectionViewCell()
    }
}

extension GameViewController: RoomItemsDelegate {
    func roomItemClick(item: Item?) {
        guard let takebleItem = item as? TakebleItem else {
            return
        }
        if gameModel != nil {
            _ = takebleItem.take(currentGame: gameModel!)
        }
    }
}
extension GameViewController: InventoryItemsDelegate {
    func inventoryItemClick(item: Item?) {
        if let clickedItem = item {
            selectedInventoryItem = item
            showItemMenuInInventory(item: clickedItem)
        }
        return
    }
}
