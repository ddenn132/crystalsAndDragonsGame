//
//  InventoryCollectionViewCell.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 29.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import UIKit

protocol InventoryItemsDelegate {
    func inventoryItemClick(item: Item?)
}

class InventoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var itemButton: UIButton!
    
    var item: Item?
    var delegate: InventoryItemsDelegate?
    
    func setItem(item: Item) {
        self.item = item
        let image = UIImage(named: item.imageName ?? "") as UIImage?
        itemButton.setImage(image, for: .normal)
        itemButton.backgroundColor = .clear
    }
    @IBAction func itemClick(_ sender: UIButton) {
        //itemButton.backgroundColor = .gray
        delegate?.inventoryItemClick(item: self.item)
    }
    
}
