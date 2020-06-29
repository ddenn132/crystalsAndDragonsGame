//
//  ViewController.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 23.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var gameFieldRowCount: UITextField!
    @IBOutlet var gameFieldColumnCount: UITextField!
    
    @IBAction func startGameButton(_ sender: Any) {
        guard let rowCount: Int = Int(gameFieldRowCount!.text ?? "0") else {
            showInfoAlert(infoTitle: "Ошибка", info: "Неправильно указано количество строк игрового поля.")
            return
        }
        guard let columnCount: Int = Int(gameFieldColumnCount!.text ?? "0") else {
            showInfoAlert(infoTitle: "Ошибка", info: "Неправильно указано количество столбцов игрового поля.")
            return
        }
        if rowCount < 3 || columnCount < 3 {
            showInfoAlert(infoTitle: "Ошибка", info: "Неправильно указаны размеры игрового поля.")
            return
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let gameVIewController = storyBoard.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        gameVIewController.setNewGame(Game(roomsInRow: rowCount, roomsInColumn: columnCount))
        self.present(gameVIewController, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showInfoAlert(infoTitle: String, info: String) {
        let alert = UIAlertController(title: infoTitle, message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понял", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}

