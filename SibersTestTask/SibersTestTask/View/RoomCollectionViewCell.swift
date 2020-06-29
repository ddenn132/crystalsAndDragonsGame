//
//  RoomCollectionViewCell.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 29.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import UIKit

protocol RoomItemsDelegate {
    func roomItemClick(item: Item?)
}

class RoomCollectionViewCell: UICollectionViewCell {
    @IBOutlet var roomItemButton: UIButton!
    var item: Item?
    var delegate: RoomItemsDelegate?
    @IBOutlet var countLabel: UILabel!
    
    func setItem(item: Item) {
        self.item = item
        let image = UIImage(named: item.imageName ?? "") as UIImage?
        roomItemButton.setImage(image, for: .normal)
        guard let moneyItem = item as? Money else {
            countLabel.isHidden = true
            return
        }
        countLabel.text = String(moneyItem.count)
        countLabel.isHidden = false
    }
    @IBAction func itemClick(_ sender: UIButton) {
        delegate?.roomItemClick(item: self.item)
    }
    
}
